require "digest"
require "set"
require 'digest/sha1'

class User < ActiveRecord::Base

  default_scope :order => 'last_name, first_name'
  
  # Table Description
  set_primary_key "user_id"

  # Table Relationships
  belongs_to :state_province
  belongs_to :country
  belongs_to :page
  
  has_many :contributions, :dependent => :destroy
  has_many :blanket_coi_forms, :order => 'coi_forms.create_date DESC', :dependent => :destroy
  has_many :role_instances, :order => 'role_id', :dependent => :destroy
  has_one  :credit_card, :dependent => :destroy
  has_many :roles, :through => :role_instances
  has_many :article_submissions, :through => :contributions, :order => 'article_submissions.create_date DESC', :dependent => :destroy
  has_many :manuscript_coi_forms, :through => :contributions, :order => 'coi_forms.create_date DESC', :dependent => :destroy
  has_many :articles, :through => :role_instances
  has_many :reviewer_subjects,:dependent=>:destroy
  has_many :article_sections,:through=>:reviewer_subjects
  has_many :manuscripts,:through=>:reviewer_manuscripts
  has_many :article_submission_reviewers
  has_many :review_articles,:through=>:article_submission_reviewers,:source=>:article_submission
  has_many :email_logs,:foreign_key=>"recipient_user_id"
  has_many :section_editor_sections,:dependent=>:destroy
  has_many :sections, :through => :section_editor_sections,:source => :article_section
  
  
  # Custom Validations (more below)
  validates_presence_of  :first_name, :last_name 
  # Got this phone validation string from: http://javascript.about.com/library/blre.htm
#  validates_format_of :phone_preferred, :with => /\A((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}\Z/, :unless => :added_as_coauthor
#  validates_format_of :phone_fax, :with => /\A^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})\Z/, :allow_blank => true, :unless => :added_as_coauthor

  validates_presence_of :phone_preferred, :unless => :added_as_coauthor
  #validates_presence_of :phone_fax, :allow_blank => true, :unless => :added_as_coauthor

  validates_length_of :employer, :in => 3..99, :unless => :added_as_coauthor
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9._]+\.)+[a-z]{2,})\Z/i
  validates_format_of :zip_postalcode, :with => /\A[0-9]{5}(( |-)?[0-9]{4})?\Z/, :if => :country_is_us?
  #validates_presence_of :state_province, :if => :country_is_us_or_ca?, :message => 'must be selected'
  validates_presence_of :degree1, :unless => :added_as_coauthor
  validates_presence_of :country, :message => 'must be selected', :unless => :added_as_coauthor
  validates_presence_of :pre_title, :unless => :added_as_coauthor
  validates_presence_of :address_1, :unless => :added_as_coauthor
  validates_presence_of :city, :unless => :added_as_coauthor
  validates_presence_of :position_title, :unless => :added_as_coauthor
  
  # Triggers
  before_create :reset_secret_token
  before_create :update_create_audit_trail
  before_validation_on_create :set_defaults

  before_save :update_save_audit_trail
  before_save :compact_degrees
  before_save :sync_email_and_username

  before_validation :normalize_data
  
  #accepts_nested_attributes_for :article_sections, :allow_destroy => true

  ########################################################################################################################
  ########################################################################################################################
  ##
  ##    Custom Methods
  ##
 

  # Returns an array of submissions the user is a reviewer or author for. Only the last revisions of each submission is returned
  def latest_version_submissions
    self.article_submissions.select{|as| as.last_revision == true && !as.is_removed?} + self.review_articles.select{|ra| ra.last_revision == true && !ra.is_removed?}
  end
 
  def isDisabled?
    return self.disabled == true
  end
  
  def save_subjects(ids,role=nil)   
    is_editor = role == "editor" 
    subjects = is_editor ? self.sections : self.article_sections
    delete_list = Array.new
    subjects.each do|s|
      if(!ids.include?s.id.to_s)
        delete_list << s
      else
        ids.delete((s.id).to_s)
      end
    end   
    
    delete_list.each do|i|
      unless is_editor
        article_sections.delete(i)
      else
        sections.delete(i)
      end
        ids.delete i.id
    end
      
    ids.each do |id|
      unless is_editor
        article_sections << ArticleSection.find(id) 
      else
        sections << ArticleSection.find(id)
      end
    end  
    return nil
  end
  
  def can_fill_out_blanket_coi?
    role_ids = self.role_instances.collect {|ri| ri.role_id}
    role_ids.include?(4) or role_ids.include?(5) or role_ids.include?(9)
  end
  
  def added_as_coauthor
    self.user_can_edit
  end
  
  def country_is_us?
    self.country_id == (@@us_id ||= Country.find_by_country_2_code('US').id) and ! :added_as_coauthor
  end
  
  def country_is_us_or_ca?
    (self.country_id == (@@us_id ||= Country.find_by_country_2_code('US').id) or 
     self.country_id == (@@ca_id ||= Country.find_by_country_2_code('CA').id)) and ! :added_as_coauthor
  end
  
  def email_link
    "<a href='mailto:#{self.email}?subject=AlphaMed Press' title='Send email to #{self.full_name}'>#{self.email}</a>"
  end
  
  def compact_degrees
    if self.degree2 == self.degree1
      self.degree2 = nil
    end
  end
  
  def sync_email_and_username
    self.username = self.email if self.email
  end

  def blanket_coi_forms_cache
    @blanket_coi_forms ||= self.blanket_coi_forms
  end
  
  def latest_blanket_coi_form
    blanket_coi_forms_cache.find(:first, :order=>"version DESC")
  end
  
  def latest_committed_blanket_coi_form
    blanket_coi_forms_cache.find(:first, :conditions=>"committed IS NOT NULL", :order=>"version DESC")
  end

  def latest_uncommitted_blanket_coi_form
    blanket_coi_forms_cache.find(:first, :conditions=>"committed IS NULL", :order=>"version DESC")
  end
  
  def problems
    #return !(self.first_name && self.last_name && (self.state_province || ! country_is_us_or_ca?) && self.email && self.employer && self.address_1 && self.city && self.zip_postalcode && self.phone_preferred)
    return !(self.first_name && self.last_name && self.email && self.employer && self.address_1 && self.city && self.zip_postalcode && self.phone_preferred)
  end
  
  def update_create_audit_trail
    self.create_date = Time.now
  end

  def update_save_audit_trail
    self.mod_date = Time.now
  end
   
  def contribution_type_other_text(contribution)
    # No text if they don't have an existing contribution    
    (contribution and contribution.id) or return nil
    
    if ! ctypes = ContributionType.find_by_user_and_contribution(self.id, contribution.id)
      return nil      
    end
    
    ctypes.each do |ctype|
      if (ctype.public == 0)
        return ctype.public
      end
    end
    
    return nil
  end
  
  
  # These must be filled in for every new user,
  # By default, their account is 'Active', with 'Author' security level, and their username = their email address
  def set_defaults
    self.active_status_id ||= 2
    self.security_level ||= 2
    self.username = self.email
    self.reset_secret_token
    #logger.info "--->Set user defaults: status:#{self.active_status_id}, security_level:#{self.security_level}, username:#{self.username}, email:#{self.email}"
  end
  
  
  def set_temp_password
    self.plain_password =  Digest::SHA1.hexdigest rand(999999999).to_s
    self.plain_password_confirmation = self.plain_password
    
    self.temp_password_flag = 1
  end
 
  # This is to generate auto-signon links to send via email
  def reset_secret_token
    self.secret_token =  (Digest::SHA1.hexdigest rand(999999999).to_s)[0..16]
  end
 
  #reset password link format: 'http://manuscriptsubmissions.theoncologist.com/r/0d0985f4bdc245661'
  def reset_password_link
    App::Config.base_url + "r/#{self.secret_token}"
  end



  # depreciated, in favor of auto_sign_in_url 
  # TODO - remove all references to this in the templates, and change to auto_sign_in_url
  def auto_sign_in_link
    auto_sign_in_url
  end

  def auto_sign_in_url
    #App::Config.base_url + "manuscripts?t=#{self.secret_token}"
    generic_auto_sign_in_address("manuscripts")
  end

  def blanket_coi_auto_sign_in_url
    #url = App::Config.base_url + "blanket_coi_forms/new?user_id=#{self.id}&t=#{self.secret_token}"
    link = "<a href='#{generic_auto_sign_in_address('blanket_coi_forms/new?user_id=' + self.id.to_s)}'>Annual Disclosure of Potential Conflicts of Interest</a>"
   # App::Config.base_url + "blanket_coi_forms/new?user_id=#{self.id}&t=#{self.secret_token}"
  end
  
  def generic_auto_sign_in_url(app_path)
    '<a href="' + generic_auto_sign_in_address(app_path) + '">click here</a>'
  end
  
  def generic_auto_sign_in_address(app_path)
    char = app_path.include?('?') ? "&" : "?"
    App::Config.base_url + "#{app_path}#{char}t=#{self.secret_token}" 
  end
  
  def full_name
    fn = name
    fn = self.pre_title + ' ' + fn unless self.pre_title.blank?
    fn
  end
  
  def name
    fn = ''
    fn = self.first_name if self.first_name
    self.middle_name.nil? or self.middle_name.strip.empty? or fn = fn + ' ' + self.middle_name
    fn = fn + ' ' + self.last_name if self.last_name
    fn
  end
  
  def rev_name
    fn = ''
    fn = fn + self.last_name if self.last_name
    fn = fn + ', ' + self.first_name if self.first_name
    self.middle_name.nil? or self.middle_name.strip.empty? or fn = fn + ' ' + self.middle_name
    fn
  end
  
  def full_name_with_degrees
    fn = full_name
    
    (1..3).each do |n|
      degree_name("degree#{n}") and fn = fn + ', ' + degree_name("degree#{n}")
    end
    
    fn
  end
  
  def degree_name(field)
    d = self.send(field)
    if d.nil? or d.empty?
      return nil
    elsif d == 'Other'
      return self.send(field + '_other')
    else
      return d
    end
  end
 
  def address
    out = ''
    self.address_1 and out += self.address_1 + ", "
    self.address_2 and out += self.address_2 + ", "
    self.state_province and out += self.state_province.state_2_code + ", " if self.state_province
    self.zip_postalcode and out += self.zip_postalcode + ", "
    self.country and out += self.country.country_name if self.country
    out
  end

  def disp_roles
    roles.compact.collect {|r| r.role_title}.uniq.join(", ")
  end
  
  

 
  # Gives a NON-Html summary of this user's details. Used in the email templates
  def info(article_submission_id = nil)
    
    out = <<HERE
  Name: #{self.full_name}
  Title: #{self.position_title}
  Institution: #{self.employer}
  Department: #{self.department}
  Address: #{self.address}
  Telephone: #{self.phone_preferred}
  Website: #{self.url}
  Email: #{self.email}
HERE

    if article_submission_id
      out += "  Contributions: #{contribution_types_list(article_submission_id)}"
    end
    out
  end
  
  
  # Gives a NON-Html summary of this user's details. Used in the email templates
  def coauthor_info(article_submission_id = nil)
    
    out = <<HERE
  Name: #{self.full_name}
  Email: #{self.email}
HERE

    if article_submission_id
      out += "Contributions: #{contribution_types_list(article_submission_id)}"
    end
    out
  end
  

  # Gives an html summary of this user's details. Used in the email templates
  def coauthor_info_html(article_submission_id = nil)
    
    out = <<HERE
  Name: #{self.full_name}<br />
  Email: #{self.email}<br />
HERE

    if article_submission_id
      out += "Contributions: #{contribution_types_list(article_submission_id)}"
    end
    out
  end
  
  
  def brief_info
    return <<HERE
  Name: #{self.full_name}
  Email: #{self.email}
HERE
end

 
 # Give a list of contribution types from this author, for a given article_submission
  def contribution_types_list(article_submission_id)
    if c = self.contributions.find_by_article_submission_id(article_submission_id)
      c.contribution_types.collect {|ctype| ctype.title}.join(", ")
    else
      return nil
    end    
  end
  
  
  def add_subject_category(section_id)   
    subject = ArticleSection.find(section_id)
    self << subject   
  end
  
  def remove_subject_category(section_id)
    self.article_sections.delete(ArticleSection.find(section_id))    
  end
  
  #############################   Authentication Methods   #################################
  
  # Virtual attribute for the unencrypted password
  attr_accessor :plain_password
#  attr_accessor :password_confirmation
  
  # Hack because we don't have this field in the legacy 'users' table
  attr_accessor :salt

  validates_presence_of     :username, :message => nil
  validates_presence_of     :plain_password_confirmation,      :if => :password_required?
  validates_length_of       :plain_password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :plain_password,                   :if => :password_required?
  validates_length_of       :email,       :within => 9..100
  validates_uniqueness_of   :email,       :case_sensitive => false
  
  
  # Human name overrides of default rails .humanize of column name. Helps us have more friendly error-messages 
  attr_human_name :plain_password => 'Password',
                  :plain_password_confirmation => 'Password Confirmation',
                  :email => 'E-mail',
                  :pre_title => 'Title',
                  :employer => 'Institution',
                  :state_province_id => 'State/Province',
                  :zip_postalcode => 'Zip/Postal Code',
                  :country_id => 'Country',
                  :phone_preferred => 'Phone',
                  :phone_work => 'Phone (work)',
                  :phone_cell => 'Phone (cell)',
                  :phone_fax => 'Phone (fax)',
                  :url => 'Website'
                  

    # as our email address and username are the same, don't give a double message on duplicate username
  # they shouldn't have an email that is the same as old style username anyway, if they do, they're hacking
  validates_uniqueness_of   :username, :case_sensitive => false, :message => nil
  
  before_save :encrypt_password
  
  # Custom Methods

  # Give our maximum access privilge
  def access_level
    if has_system?
      'system'
    elsif has_admin?
      'admin'
    elsif has_editor?
      'editor'
    elsif has_registered?
      'registered'
    elsif has_read_only?
      'read_only'
    end
  end
  
  def has_system?
    self.security_level >= 5 or self.has_role?(:admin)
  end
  def has_admin?
    self.security_level >= 4 or self.has_role?(:user)
  end
  def has_editor?
    self.security_level >= 3
  end
  def has_registered?
    self.security_level >= 2
  end
  def has_read_only?
    self.security_level >= 1
  end
  # Notice! This is a deviation from our standard in the previous 4 access level tests
  # This is to provide a way to ask if the user has no access level.
  def has_none?
    self.security_level.to_i == 0
  end

  # Determine if they have a role, by expanding all their roles, and looking for the required role in that array
  def has_role?(role_required)
    Role.has_expanded_role?(self.roles, role_required)
  end 



  # Authenticates a user by their username name and unencrypted password.  Returns the user or nil.
  def self.authenticate(username, plain_password)
    #logger.info("username: #{username} plain_password: #{plain_password}")
#    return false if plain_password.nil? or plain_password.blank?
    u = find_by_email(username)  # need to get the salt
    u ||= find_by_username(username) # legacy support for usernames diff than email
    
    u && u.authenticated?(plain_password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(plain_password, salt = nil)
    #Digest::SHA1.hexdigest("--#{salt}--#{plain_password}--")
    # Use the same encryption scheme as the existing Pubforecaster
    Digest::SHA1.hexdigest("#{plain_password}")
  end

  # Encrypts the plain_password with the user salt
  def encrypt(plain_password)
    self.class.encrypt(plain_password, salt)
  end

  def authenticated?(plain_password)
  #  logger.info("password: #{password} given: #{encrypt(plain_password)} -#{plain_password}-")
    password == encrypt(plain_password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end


  def blanket_coi_roles
      role = ""
    if self.has_role?(:senior_editor)
     role = Role.find_by_key('senior_editor').role_title
    elsif self.has_role?(:editor)
     role = Role.find_by_key('editor').role_title
    end  
    return role   
  end

  def potential_coi_info 
    out = ''
    coi = latest_committed_blanket_coi_form
    out += "<div>" + self.full_name + ":</div>"
    if coi
      if coi.conflicts or coi.employment or coi.ip or coi.consultant or coi.honoraria or coi.research or coi.ownership or coi.expert or coi.other or ! coi.unbiased
        if coi.conflicts
          out += '<span style="font-weight:bold;">Has reported conflicts:</span><br />'
          ['employment', 'ip', 'consultant', 'honoraria', 'research', 'ownership', 'expert', 'other'].each do |t|
            if coi.send(t)
              out +=  t.humanize + ": <span style='color:blue;'>" + coi.send(t + "_details") + '</span> <br />'
            end
          end
          coi.unbiased || out += "Can provide an unbiased review?: <span style='color:blue;'>No</span><br />"
        end
      else
        out += "No reported conflicts" + '<br />'
      end
    else
      out += "<span style='color:blue;'>Blanket COI form is outstanding</span>"
    end
    out
  end
  
 def self.merge_users(old_user,new_user)
    new_user.contributions << old_user.contributions
    new_user.blanket_coi_forms << old_user.blanket_coi_forms
    new_user.credit_card = old_user.credit_card unless new_user.credit_card
    new_user.role_instances << old_user.role_instances
    new_user.article_submissions << old_user.article_submissions
    #new_user.articles << old_user.articles
    new_user.article_sections << old_user.article_sections
    new_user.article_submission_reviewers << old_user.article_submission_reviewers
    new_user.review_articles << old_user.review_articles
    new_user.email_logs << old_user.email_logs    
    new_user.save
  end
  
    def save_sections(ids)
      sections = self.sections
      delete_list = Array.new
      sections.each do|s|
        if(!ids.include?s.id)
          delete_list << s
        else
          ids.delete s.id
         end
      end      
      delete_list.each do|i|
        self.article_sections.delete(i)
        ids.delete i.id
      end    
      ids.each do |id|
        self.article_sections << ArticleSection.find(id) 
      end  
  end

  
  
 
  private 
  
  def normalize_data
    self.email && self.email.gsub!(/\s+/,'')
    self.email.strip!
    self.first_name.strip!
    self.last_name.strip!
  end



  protected
    # before filter 
    def encrypt_password
      return if self.plain_password.blank?
      #self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--") if new_record?
      self.salt = nil
     # logger.info("encrypting:  -#{self.plain_password}- to: -#{encrypt(plain_password)}-")
      self.password = encrypt(self.plain_password)
    end
    
    def password_required?
      password.blank? || !plain_password.blank?
    end
end
