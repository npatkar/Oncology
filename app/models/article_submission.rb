class ArticleSubmission < ActiveRecord::Base

 COVER_LETTER_RESUBMITTED = "article_submission_cover_letter_resubmitted"
 MANUSCRIPT_RESUBMITTED = "article_submission_manuscript_resubmitted"
 PROVISIONALLY_ACCEPTED = "article_submission_provisionally_accepted"
 IN_REVIEW = "article_submission_in_review"
 FORMS_RECIEVED = "article_submission_forms_received"
 ADMIN_REMOVED = "article_submission_admin_removed"
 REMOVED =  "article_submission_removed"
 SUBMITTED = "article_submission_submitted"
 STARTED = "article_submission_started"
 STATUS_SQL=<<SQL
 select a.* from
      (select s.key,ar.*,es.created_at as status_date,es.id as entity_id,es.trackable_id,es.created_at  from article_submissions ar,entity_statuses es,statuses s
      where es.trackable_id = ar.id and es.trackable_type = 'ArticleSubmission'
      and es.status_id = s.id and s.key = ?) a,
      (select es.trackable_id,es.id from
      (select trackable_id as trackable_id,max(created_at) as max_created from entity_statuses 
      where trackable_type = 'ArticleSubmission' group by trackable_id)
      as x inner join entity_statuses as es on es.trackable_id = x.trackable_id
      and es.created_at = x.max_created) b
      where a.entity_id= b.id order by a.create_date
SQL
 
include EntityMixin

has_many :article_submission_reviewers
has_many :reviewers,:through=>:article_submission_reviewers,:source=>:user
has_one :updated_manuscript   
has_many :cadmus_submission_logs


  ############################### CLASS METHODS ###############################

  def self.find_all_in_current_status(key)
     sql = <<SQL
      select a.* from
      (select s.key,ar.*,es.created_at as status_date,es.id as entity_id,es.trackable_id,es.created_at  from article_submissions ar,entity_statuses es,statuses s
      where es.trackable_id = ar.id and es.trackable_type = 'ArticleSubmission'
      and es.status_id = s.id and s.key = "#{key}") a,
      (select es.trackable_id,es.id from
      (select trackable_id as trackable_id,max(created_at) as max_created from entity_statuses 
      where trackable_type = 'ArticleSubmission' group by trackable_id)
      as x inner join entity_statuses as es on es.trackable_id = x.trackable_id
      and es.created_at = x.max_created) b
      where a.entity_id= b.id order by a.committed, a.create_date
SQL
     
     self.find_by_sql(sql)
   end



  def self.find_by_status(status_key, options = nil)
    options ||= {}
    options[:end_date] ||= Date.today
    options[:start_date] ||= Date.today - 1.year
    options[:order] ||= 'create_date'
    options[:committed] ||= nil

    status_key = status_key.to_s
    all = ArticleSubmission.find(:all,
                                 :include => :entity_statuses,
                                 :order => options[:order])
    all.select {|as| as.has_current_status_of?(status_key)}
  end

  # Return all article submissions that meet specific criteria set by 'options'
  # TODO: Fix committed_befre / after and end_date / start_date (this doesn't work right now) (AMA - 12 Nov 2010)
  def self.find_all_by_status(options = nil)
    options ||= {}
    options[:end_date] ||= Date.today
    options[:start_date] ||= Date.today - 1.year
    options[:order] ||= 'create_date'
    options[:statuses_to_keep] ||= []
    options[:statuses_to_drop] ||= []
    options[:committed_before] ||= nil
    options[:committed_after] ||= nil

    conditions = "1"
    if options[:committed_before]
      conditions += " AND `committed` <= #{options[:committed_before].strftime('%Y-%m-%d')} "
    end
    all = ArticleSubmission.find(:all,
                                 :include => :entity_statuses,
                            #     :conditions => ["create_date BETWEEN ? AND ?", options[:start_date].strftime("%Y-%m-%d"), options[:end_date].strftime("%Y-%m-%d")],
                                 :order => options[:order])

    # If specified the statuses_to_keep option, delete all groups that don't have one of these specified keys
    if options[:statuses_to_keep] != []
      all.delete_if {|as| !as.current_status || !options[:statuses_to_keep].include?(as.current_status.key)}
    end

    # If specified statuses to delete, delete all groups that have one of these statuses
    if options[:statuses_to_drop] != []
      all.delete_if {|as| as.current_status && options[:statuses_to_drop].include?(as.current_status.key)}
    end

    all
  end

  def self.find_all_and_group_by_status(options = nil)
    options ||= {}
    options[:end_date] ||= Date.today
    options[:start_date] ||= Date.today - 1.year
    options[:order] ||= 'create_date'
    options[:statuses_to_keep] ||= nil
    options[:statuses_to_drop] ||= nil
    options[:committed_before] ||= nil
    options[:committed_after] ||= nil

    conditions = "1"
    if options[:committed_before]
      conditions += " AND `committed` <= #{options[:committed_before].strftime('%Y-%m-%d')} "
    end
    all = ArticleSubmission.find(:all,
                                 :include => :entity_statuses,
                            #     :conditions => ["create_date BETWEEN ? AND ?", options[:start_date].strftime("%Y-%m-%d"), options[:end_date].strftime("%Y-%m-%d")],
                                 :order => options[:order])
    all_grouped = all.group_by(&:current_status_key)

    # If specified the statuses_to_keep option, delete all groups that don't have one of these specified keys
    if options[:statuses_to_keep]
      all_grouped.delete_if {|key, value| !options[:statuses_to_keep].include?(key)}
    end

    # If specified statuses to delete, delete all groups that have one of these statuses
    if options[:statuses_to_drop]
      options[:statuses_to_drop].each {|status_key| all_grouped.delete(status_key.to_s)}
    end

    all_grouped
  end



  # Return a hash of Article Submissions that are in the review status, with the key being the 'special status' of the submission
  def self.in_review_grouped_by_status(options = nil)
    article_submissions_in_review = ArticleSubmission.find_by_status(ArticleSubmission::IN_REVIEW, options)
    article_submissions_in_review.group_by(&:special_status_by_reviewers)
  end

   def self.find_by_manuscript_number(num) 
     results = Article.find(:all, :conditions => ["manuscript_num LIKE ?", "#{num}%"])
     subs = Array.new
     results.each do |a|
       subs.concat(a.article_submissions)
     end
     return subs
   end
   

  ################### Instance Methods ##################

  # Return a special classification of an article submission, based on the status of 
  # all the respective article submission reviewers
  def special_status_by_reviewers
    asrs = self.article_submission_reviewers.group_by(&:current_status_key)
    total = self.article_submission_reviewers.length
    asrs['reviewer_recieved_comments'] ||= []
    asrs['reviewer_not_yet_invited'] ||= []
    asrs['reviewer_invited_awaiting_response'] ||= []
    asrs['reviewer_declined_with_alternate'] ||= []
    asrs['reviewer_need_comments'] ||= []
    asrs['reviewer_given_up'] ||= []

    asrs['comments_overdue'] = asrs['reviewer_need_comments'].select {|asr| asr.comments_overdue?}

    if total == 0 
      return 'Need reviewers'
    elsif asrs['reviewer_recieved_comments'].length == total
      return 'All comments received'
    elsif asrs['comments_overdue'].length >= 1
      return 'Late comments'
    elsif asrs['reviewer_invited_awaiting_response'].length > 0
      return 'Requests sent to reviewers'
    elsif asrs['reviewer_not_yet_invited'].length > 0
      return 'Reviewers not yet invited'
    else
      return 'With reviewers'
    end
  end
  
  # access method as write_attribute is private in rails3
  def write_attribute_3(param1, param2)
	write_attribute(param1, param2)
  end

  # dirty nasty ugly hack TODO get this into the controller!!!
  def sections(form_state = nil)
  if form_state.nil?
     return :general
    else
     case form_state
        when :general
             puts "Hello world now 1 in perfect method case latest"            
	     { :title=>'General Info', :next=>:reviewers, :prev=>nil}
        when :coauthors
         {:title=>'Co-Authors', :next=>:reviewers, :prev=>:general}
        when :reviewers
         {:title=>'Reviewers', :next=>:fees, :prev=>:general}
        when :fees
              {:title=>'Fees', :next=>:checklist, :prev=>:reviewers}
        when :checklist
         {:title=>'Checklist', :next=>:nil, :prev=>:fees}
        
        when :review
         {:title=>'Review', :next=>nil, :prev=>:nil}
      end
    end
  end

  attr_accessor :num_authors
  attr_accessor :user_id
  attr_accessor :form_state

  # Table Relationships
  belongs_to :article
  
  has_many :contributions,
    :order => "contributions.role_id",
    :dependent => :destroy
    
  has_many :users,
    :through => :contributions,
    :order => "users.last_name, users.first_name"
  
  has_many :coauthors,
    :class_name => "User",
    :through => :contributions,
    :conditions => "contributions.role_id = 2",
    :source => :user,
    :order => "users.last_name, users.first_name"

  has_many :coauthor_contributions,
    :class_name => "Contribution",
    :conditions => "contributions.role_id = 2"

  has_one :corresponding_author_contribution,
    :class_name => "Contribution",
    :conditions => "contributions.role_id = 1"
  
    
  has_one :corresponding_author, 
    :class_name => "User",
    :through => :contributions,
    :conditions => "contributions.role_id = 1",
    :source => :user
  
  has_many :additional_files,
    :dependent => :destroy
    
  has_many :manuscripts,
    :dependent => :destroy
    
  has_many :cover_letters,
    :dependent => :destroy
    
  has_many :permissions,
    :dependent => :destroy

  has_many :manuscript_coi_forms,
    :through => :contributions 

  has_many :charges,
    :dependent => :destroy

  has_one :initial_charge,
    :class_name => "Charge",
    :conditions => {:charge_type_id => 1},
    :dependent => :destroy
 
  has_one :pub_charge,
    :class_name => "Charge",
    :conditions => {:charge_type_id => 2},
    :dependent => :destroy
  
  has_many :cadmus_submission_logs
  
  belongs_to :manuscript_type,:foreign_key=>:manuscript_type_id
   
 
#  has_many :reviewing_instances,
#    :dependent => :delete_all
  
#  has_many :reviewers,
#    :class_name => "User",
#    :through => :reviewing_instances,
#    :source => :user
    
  belongs_to :article_section

  belongs_to :review_pdf,
    :class_name => 'Pdf',
    :dependent => :destroy,
    :foreign_key => :review_pdf_id

  belongs_to :article_submission,:foreign_key=>:parent_id
  has_many :article_submissions,:foreign_key =>:parent_id, :order=>:version, :dependent=>:destroy
  before_validation :normalize


  ## Validations
  
  validates_presence_of :manuscript_type_id
  
  # Validations to run on all pages of multi-page form
  validates_presence_of :title, :article_section_id,:abstract,:num_pages, :num_refs, :num_tables, :num_figures, :num_suppl_mtrls, :short_title

validates_inclusion_of :sole_author, :in => [true, false],:message=>"status must be selected"
  validates_inclusion_of :num_pages, :in => 1..99, :message=>"must be greater than 0",:unless=>:isVideo?
  validate :check_tables_figures_valid?
  
  
  # Validations to run on the Fees page
  validates_inclusion_of :invited, :in => [true, false], :if => :fees_state?, :message=>'has not been answered'
  validates_inclusion_of :is_letter, :in => [true, false], :if => :fees_state_and_invited_set?, :message=>'has not been answered'
  validates_presence_of :payment_type, :if => :fees_state_and_can_pay?,:message=>'must be specified'
  validates_presence_of :fees_pubfee_status, :if => :fees_state_and_need_to_pay_and_not_exempt?,:message=>'must be specified'

  validates_presence_of :cant_pay_reason, :if => :fees_state_and_cant_pay?
  
  # Checklist validations
 # validates_inclusion_of :incl_best_practices, :in => [true, false], :if => :checklist_state?, :message=>'has not been answered'
  #validates_inclusion_of :incl_abstract, :in => [true, false], :if => :checklist_state?, :message=>'has not been answered'
  #validates_inclusion_of :incl_keywords, :in => [true, false], :if => :checklist_state?, :message=>'has not been answered'
  #validates_inclusion_of :incl_two_strategies, :in => [true, false], :if => :checklist_state?, :message=>'has not been answered'
  #validates_inclusion_of :incl_learn_obj, :in => [true, false], :if => :checklist_state?, :message=>'has not been answered'
  validates_inclusion_of :indemnify, :in => [true, false], :if => :checklist_state?, :message=>'has not been answered'


  # Serialized reviewers - Hash{:pre_title, :first_name, :last_name, :email, :employer}
  serialize :reviewer1, Hash
  serialize :reviewer2, Hash
  serialize :reviewer3, Hash


 
  # Override the default column names so our error messages are more friendly
  attr_human_name 'article_section_id' => 'Primary Subject Category',
                  'num_pages' => 'Pages',
                  'num_refs' => 'References',
                  'num_tables' => 'Tables',
                  'num_figures' => 'Figures',
                  'num_supple_mtrls' => 'Supplemental Materials',
                  
                  'fees_pubfee_status' => 'Publication Fee Payment',
                  'cant_pay_reason' => 'Publication Fee Payment Explanation',
    
                  'incl_best_practices' => 'Best Practices',
                  'incl_abstract' => 'Abstract',
                  'incl_keywords' => 'Keywords',
                  'incl_two_strategies' => 'Strategies',
                  'incl_learn_obj' => 'Learning Objectives',
                  'indemnify' => 'Obtained Written Consent',
                  'learn_obj_1' => 'Learning Objective 1',
                  'learn_obj_2' => 'Learning Objective 2',
                  'gap_1' => 'Gap Analysis 1',
                  'gap_2' => 'Gap Analysis 2',
                  'gap_3' => 'Gap Analysis 3',
                  'is_letter' => "Letter Option"


  ## Triggers
  before_save :update_save_audit_trail
  before_create :update_create_audit_trail
  
  
  # Methods
  
  def set_version! 
      self.reload
      parent = self.article_submission
      parent.reload
      parent.update_attribute(:version, 1) if parent && parent.version.nil?
      unless parent.nil?
        revisions = parent.article_submissions
        if self == revisions.first
          self.update_attribute(:version, 2)
        else
          revs = revisions.reject{|a|a==self}
          last_version = revs.last.version || 1
          self.update_attribute(:version, last_version + 1)
        end
      end
  end
  
  
  
  def copy(copy_statuses)
    new = self.clone
    #new.article_submission = self
    new.save(false)
    self.contributions.each do|c|
      new_c = c.clone 
      new_c.contribution_types << c.contribution_types
      new.contributions << new_c
    end
    if copy_statuses
      self.entity_statuses.each do |es|
        new.entity_statuses << es.clone
      end
    end
    
    return new
  end


  # Remove and rebuild the contributions for this article submssion
  # This is to fix the problem where the original copy function did not copy the contribution_types for each contribution
  # WARNING!!! This will delete all modifications to this contriubtion, including COI forms associated with this particular revision
  def rebuild_contributions(copy_statuses)
    p = self.parent

    self.contributions.destroy_all

    p.contributions.each do|c|
      new_c = c.clone
      new_c.contribution_types << c.contribution_types
      self.contributions << new_c
    end
  end


  # Creates a new revision of an article submission
  # copying this object to the new revision
  # sets the parent of the new revision to this object
  # sets the 'last_revision' attribute of this object to false, as the revision is now the latest
  # nulls out these attributes:
  #   resubmitted
  #   committed
  # Adds the reviewers to the new revision, but marks them as uninvited
  def create_revision!
    logger.info("Creating a new revision for article_submission id: #{self.id}")
    rev = self.copy(false)
    unless rev.article_submission
        rev.article_submission = self 
        self.update_attribute(:last_revision,false)
    else
      rev.article_submission.article_submissions.each do |as|
        as.update_attribute(:last_revision,false)
      end
    end
    
    rev.resubmitted = nil
    rev.committed = nil
    rev.last_revision = true
    rev.save(false)     
    rev.set_version!
    self.article_submission_reviewers.each do |ar|
        reviewer = ar.clone
        reviewer.change_status(ArticleSubmissionReviewer::NOT_YET_INVITED)
        rev.article_submission_reviewers << reviewer
    end
    rev.change_status(ArticleSubmission::STARTED)
    rev.increment_manuscript_rev_num

    return rev
  end

  # Returns true when this object is the original submission 
  def is_original?
     return self.parent_id.nil? || self.parent_id == self.id
  end
  
  def siblings
    unless self.is_original?
      sibs = Array.new
      sibs << self.parent
      subs = self.parent.article_submissions.reject{|as|as.isRemoved?}
      return sibs.concat(subs)
    else
      [self]
    end
  end
  
  def man_type
    if self.manuscript_type
       self.manuscript_type.name
    else
       return ""
    end
  end
   
  
  def normalize
    self.title = self.title.downcase.titleize unless self.title.blank?
    
    # Payment type should not be set if they chose invited, but could be an artifact
    if self.invited? and self.payment_type
      logger.info("*** payment type should not be set to: #{self.payment_type}.. Zeroing out payment_type.")
      self.payment_type = nil 
    end
  end
  
  def reviewers_valid?
    reviewer_errors = []
    [1,2,3].each do |n|
      reviewer = "reviewer#{n}"
      self.send(reviewer) || write_attribute(reviewer.to_sym, {})
      blank_field = false
      filled_field = true 
      [:first_name, :last_name, :employer, :email].each do |attr|
        #errors.add attr, 'must be completed' if read_attribute(attr).blank?
        if self.send(reviewer)[attr].blank?
          blank_field = true
        else
	  filled_field = false
        end
        reviewer_errors << reviewer unless (blank_field && filled_field) or (! blank_field && ! filled_field)
#        reviewer_errors = true  if self.send(reviewer)[attr].blank?
      end
    end
    reviewer_errors.empty?
  end
  
  
  
  def check_tables_figures_valid?
    #logger.info("***** num_tables: #{self.num_tables} num_figures #{self.num_figures}, #{self.num_tables + self.num_figures}")
    if (self.num_tables + self.num_figures) > 7
      errors.add(:num_tables, " + figures cannot exceed 7")
      false
    else
      true
    end
  end
  
  def commit
    logger.info("Committing submission with id: '#{self.id}'")
    self.update_attribute('committed', Time.now) unless problems 
  end

  def contribution_by_user_id(user_id)
    self.contributions.find_by_user_id(user_id)
  end

  def cacontribution
    contribution_by_user_id(self.corresponding_author.id)
  end
 
  def copyright_pdfs
    self.contributions.collect {|c| c.copyright_pdf}.compact || []
  end
 
  def responsibilities_pdfs
    self.contributions.collect {|c| c.responsibilities_pdf}.compact || []
  end
 
  def latest_manuscript_coi_form_by_user_id(user_id)
    parent_to_use = contribution_by_user_id(user_id) || self.article_submission_review_by_user_id(User.find(user_id))
    parent_to_use.latest_manuscript_coi_form
  end
#  <% coi_form = CoiForm.find_by_sql('SELECT coi_forms.*
#                FROM coi_forms INNER JOIN contributions ON coi_forms.contribution_id = contributions.id
#                INNER JOIN article_submissions ON contributions.article_submission_id = article_submissions.id
#                INNER JOIN users ON contributions.user_id = users.user_id
#                WHERE article_submission.id = 9 AND user_id = 10
#                ORDER BY coi_forms.version DESC') %>
          
  
  # Give "general article submission information", created so user_template can easily include it
  def general_info
    return <<HERE
  Manuscript Title: #{self.title}<br />
  Manuscript Type: #{self.manuscript_type.name}<br />
  Main Subject Category: #{self.article_section.article_section_name}<br />
  Manuscript Counts<br />
    Pages: #{self.num_pages}<br />
    References: #{self.num_refs}<br />
    Tables: #{self.num_tables}<br />
    Figures: #{self.num_figures}<br />
    Supplemental Materials: #{self.num_suppl_mtrls}<br />
    Co-Authors: #{self.coauthors.count}<br />
HERE
  end
  
  #added for cadmus report
  def section_header
    
  unless self.article_section.nil?
    return self.article_section.article_section_name
  else
    return ""
  end
    
 end
  
  
  # Give a list of contribution types from a given author, for this article_submission
  def contribution_types_list(user_id)
    if c = self.contributions.find_by_user_id(user_id)
      c.contribution_types.collect {|ctype| ctype.title}.join(", ")
    else
      return nil
    end    
  end
  
  def coauthor_info
    out = ''
    if self.coauthors.length > 0
      self.coauthors.each do |ca|
        out += ca.coauthor_info(self.id)
        out += "\n\n<br /><br />"
      end
    else
      out += "No Co-Authors listed<br />"
    end
    out
  end

  def authors
    [corresponding_author].concat(self.coauthors)
  end

  def authorinfohtml
    authors.collect {|ca| ca ? ca.full_name : 'corresponding author was deleted'}.join(", ")
  end
 
  def receiptinfohtml
    committed ? committed.strftime("%x %I:%M%p %Z") : 'Not submitted'
  end

  def reviewers_info
    out = ''
    [1,2,3].each do |n|
      a = "reviewer#{n.to_s}"
      if reviewer = self.send(a) and !reviewer[:last_name].blank?
         out += reviewer[:last_name] + ', ' + reviewer[:first_name] + '; ' + reviewer[:employer] + '; ' + reviewer[:email] + "\n<br />"
      end
    end
    out
  end
 
  def invitedinfohtml
    self.invited ? "Yes" : "No"
  end


  def fees_info
    out = ''
    out += "<br/> Was this an invited manuscript? "
    out += self.invited ? "Yes\n<br/>" : "No\n<br/>"
    #out += self.invited ? "Yes, invited by #{self.invited_by}\n" : "No\n"
    out += "Was this a Letter to the Editor, eLetter, or Reflections piece?"
     out += self.is_letter ? "Yes\n<br/>" : "No\n<br/>"
    if !(self.invited || self.is_letter)
      if self.payment_type != 'exempt'
        out += "  A $50 (USD) non-refundable manuscript processing fee is due when the complete submission package has been submitted.\n<br />"
      end
      
      payment_type = self.payment_type.blank? ? "N\A" : self.payment_type.capitalize
      out += "  How will you pay the processing fee?  #{payment_type}"
      if self.payment_type == 'check'
        out += "\n  Please mail your $50 (USD) check to: <br /> AlphaMed Press, 318 Blackwell St., Suite 260, Durham, North Carolina 27701-2884 USA.\n<br />"
        out +=   "  Note: To ensure that the check is applied to the appropriate submission, please include the corresponding author's name on the check.\n<br />"
      elsif  self.payment_type == 'credit' and self.corresponding_author.credit_card
        out += "  #{self.corresponding_author.credit_card.cc_type}\n<br />"
      #  out += "  #{self.corresponding_author.credit_card.name}:#{self.corresponding_author.credit_card.num_masked} exp #{self.corresponding_author.credit_card.exp_mo}/#{self.corresponding_author.credit_card.exp_yr}\n"
      #  out += "  billing zip/postal code: #{self.corresponding_author.credit_card.zip}\n"
      end
    end
    out
  end
 
  def submissionfileshtml
    out = '<br />'
    if self.manuscript && self.manuscript.file
      link = App::Config::base_url.chop + self.manuscript.file.url 
      out += "<a href='#{link}'>#{self.manuscript.file.filename}</a><br />"
    else
      out += "No manuscript uploaded<br />" 
    end
    if self.cover_letter && self.cover_letter.file
      link = App::Config::base_url.chop + self.cover_letter.file.url
      out += "<a href='#{link}'>#{self.cover_letter.file.filename}</a><br />"
    else
      out += "No cover letter uploaded<br />" 
    end
    if self.additional_files.count > 0 
      self.additional_files.each do |af| 
        link = App::Config::base_url.chop + af.file.url
        out += "<a href='#{link}'>#{af.file.filename}</a><br />"
      end
    else
      out += "No additional files uploaded<br />" 
    end
    if self.permission && self.permission.file
      link = App::Config::base_url.chop + self.permission.file.url
      out += "<a href='#{link}'>#{self.permission.file.filename}</a><br />"
    else
      out += "No permissions file uploaded<br />" 
    end
    out
  end 

  def learnobjhtml
    out = '<br />'
    (1..3).each do |n|
      m = "learn_obj_#{n}"
      if self.send(m)
        out += "#{n}. #{self.send(m)}" + "<br />"
      else
        out += "#{n}. None <br />"
      end
    end
    out
  end

def has_learn_obj?
     has_it = false
    (1..9).each do |n|
      m = "learn_obj_#{n}"
      if self.send(m)
        has_it = true
        break
      end
    end
   
    return has_it
 end
  

  def gapanalysishtml
    out = '<br />'
    (1..9).each do |n|
      m = "gap_#{n}"
      if self.send(m)
        out += "#{n}. #{self.send(m)}" + "<br />"
      else
        out += "#{n}. None <br />"
      end
    end
    out
  end

 def has_gap_analysis?
     has_it = false
    (1..9).each do |n|
      m = "gap_#{n}"
      if self.send(m)
        has_it = true
        break
      end
    end
   
    return has_it
 end
  
  def checklist_info
    out = ''
    out += <<HERE
  Description of current and best practices: #{yes_or_no(self.incl_best_practices)} <br />
  Four to six keywords or phrases, using terms from the most recent Medical Subject Headings of Index Medicus: #{yes_or_no(self.incl_keywords)}<br />
  Three learning objectives readers should expect to achieve once they have read the article: #{yes_or_no(self.incl_learn_obj)}<br />
  I represent to AlphaMed Press that I have obtained written consent of all other authors to sign this form on their behalf, and indemnify AlphaMed Press for any breach of this representation: #{ yes_or_no(self.indemnify)}<br />
HERE
  #Two strategies learners should be able to implement in their practices as a result of completing this CME activity: #{yes_or_no(self.incl_two_strategies)}
    out
  end
 
  def authorpotentialcoiinfo
    out = ''
    self.contributions.each do |c|
      coi = c.latest_committed_manuscript_coi_form
      out += "<br /><strong>" + c.user.name + "</strong>: <br />"
      if coi
        if coi.conflicts or coi.alternative_use or coi.employment or coi.ip or coi.consultant or coi.honoraria or coi.research or coi.ownership or coi.expert or coi.other
          if coi.alternative_use
            out += "Alternative Use: <span style='color:blue;'>" + coi.alternative_use_details + '</span> <br /> '
          end
          if coi.conflicts
            ['employment', 'ip', 'consultant', 'honoraria', 'research', 'ownership', 'expert', 'other'].each do |t|
              if coi.send(t)
                out +=  t.humanize + ": <span style='color:blue;'>" + coi.send(t + "_details") + '</span> <br />'
              end
            end
          end
        else
          out += "No reported conflicts" + '<br />'
        end 
      else
        out += "<strong><span style='color:blue;'>COI form is outstanding</span></strong>" 
      end
    end
    out
  end



 def reviewer_potential_coi_info
    out = ''
    self.article_submission_reviewers.each do |asr|
      coi = asr.latest_committed_manuscript_coi_form
      out += "<div>" + asr.reviewer.full_name+ ":</div>"
      if coi
        if coi.conflicts or coi.alternative_use or coi.employment or coi.ip or coi.consultant or coi.honoraria or coi.research or coi.ownership or coi.expert or coi.other
          if coi.alternative_use
            out += "Alternative Use: <span style='color:blue;'>" + coi.alternative_use_details + '</span> <br /> '
          end
          if coi.conflicts
            ['employment', 'ip', 'consultant', 'honoraria', 'research', 'ownership', 'expert', 'other'].each do |t|
              if coi.send(t)
                out +=  t.humanize + ": <span style='color:blue;'>" + coi.send(t + "_details") + '</span> <br />'
              end
            end
          end
        else
          out += "No reported conflicts" + '<br />'
        end 
      else
        out += "<span style='color:blue;'>COI form is outstanding</span>" 
      end
    end
    out
  end


  def first_author
      author = nil
      self.contributions.each do|c|
         if(c.first_author)
            author = c.user
         end     
     end    
      return author 
  end
  
  
  #Puts first author first
  def co_author_list  
   if self.first_author 
     list = [self.first_author]
     list.concat self.coauthors.reject{|ca|ca ==self.first_author}
     return list
   else
     return self.coauthors
   end
  end
  
  
  def authorcopyrightinfo
    out = ''
    self.contributions.each do |c|
      out += "<br /><strong>" + c.user.name + "</strong>: "
      if c.copyright_sig_time
        out += "Copyright Assignment Complete"
      else
        out += "<strong><span style='color:blue;'>Copyright Assignment form is outstanding</span></strong>"
      end
    end
    out
  end
  

  def authorcontributionsinfo
    all_ctypes = ContributionType.find_all_by_public('1', :order => :display_order)
    out = '<table border=1 cellpadding=1 cellspacing=0 style="font-size: .8em; width: 500px" >'
    out += '<tr>'
    out += '<th></th>'
    contributions.each do |c|
      out += "<th>#{c.user.name}</th>"
    end
    out += '</tr>'
    all_ctypes.each do |ctype|
      out += '<tr>'
      out += "<th>#{ctype.title}</th>"
      contributions.each do |c|
        out += '<td style="text-align: center;">'
        if c.contribution_types.include?(ctype)
          out += 'X'
        end
        out += '</td>'
      end
      out += '</tr>'
    end
    out += '<tr>'
    out += "<th>Other</th>"
    contributions.each do |c|
      out += '<td>'
      if ctype = c.contribution_types.find_by_public('0')
        out += ctype.title
      end
      out += '</td>'
    end
    out += '</tr>'  
    out += '</table>'
  end


def authorcontributionsinfo_as_text
    out = ""
    contributions.each do |c|
        out += "#{c.user.name}:"
        conts = c.contribution_types.collect{|ct|ct.title}
        out+=conts.join(",")
        types = c.contribution_types
        if ctype = types.find_by_public('0')
          out += ctype.title
        end
        out+="\r\n"
    end
   return out  
end


  def medicalwriterinfo
    'TODO: auth potential coi_info goes here'
  end

  def coverletternotes
    'TODO: cover_letter_notes'
  end

  
  def progress(current_user=nil)
    user = current_user || self.corresponding_author
  
    progress = {}   
    progress[:general] = {:completed? =>page_valid?(:general)}
    unless self.sole_author
      progress[:coauthors] = {:completed? => coauthors_valid?}
    end
    progress[:reviewers] = {:completed? =>reviewers_complete?}
    progress[:fees] = {:completed? =>page_valid?(:fees)}
    progress[:checklist] = {:completed? =>page_valid?(:checklist)}
    progress[:review] = {:completed? =>page_valid?(:review)}
    progress[:coi] = {:completed? =>completed_coi?(user)}
    logger.info("#{self.id}-----------#{user.id}")
    contr = Contribution.find_by_article_submission_and_user(self.id, user.id)  
    time_stamp = contr.latest_committed_manuscript_coi_form.committed.strftime("%x %I:%M%p %Z")if contr.latest_committed_manuscript_coi_form
    progress[:coi][:time_stamp] = time_stamp if progress[:coi][:completed?]
    progress[:responsibilities] = {:completed? =>!contr.responsibilities_sig_assent.nil?}
    progress[:copyright] = {:completed? =>!contr.copyright_sig_assent.nil?}  
    progress[:manuscript] = {:completed? => !self.manuscript.nil? || self.isVideo?}
    progress[:cover_letter] = {:completed? =>!self.cover_letter.nil? || self.isVideo?}
#    if(self.provisionally_accepted)
#      progress[:manuscript_resubmitted] = {:completed? => manuscript_resubmitted?}
#      progress[:cover_letter_resubmitted] = {:completed? => cover_letter_resubmitted?}
#      progress[:forms_in] = {:completed? =>all_forms_in?}
#    end
    if self.isVideo?
      progress[:manuscript_video] = {:completed? =>!self.manuscript_video_link.blank?}
    end
    
    return progress,contr
  end
  
  def all_forms_in?
    forms_in = false
    self.contributions.each do |contr|   
      forms_in = contr.forms_complete?
      break unless forms_in
    end  
    return forms_in
  end
  
  
  
  
  
  def manuscript_valid?
     if self.provisionally_accepted
        return manuscript_resubmitted?
     else
        return !self.manuscript.nil? || self.isVideo?
     end
   end
   
   def cover_letter_valid?
     if self.provisionally_accepted
       return cover_letter_resubmitted?
     else
        return !self.cover_letter.nil? || self.isVideo?
     end
   end

   
  def manuscript_resubmitted?
    return self.manuscript && self.provisionally_accepted && self.has_had_status?(ArticleSubmission::MANUSCRIPT_RESUBMITTED)
  end
  
   def cover_letter_resubmitted?
    return self.cover_letter && self.provisionally_accepted && self.has_had_status?(ArticleSubmission::COVER_LETTER_RESUBMITTED)
  end
  
  
  def reviewers_complete?
    (1..3).each do|i|
      reviewer = "reviewer#{i}"      
      return true if self.send(reviewer)     
    end
    return false
  end
  
  def isComplete? progress   
    complete = true
    progress.values.each do |value|
        step_done = value[:completed?]
        unless step_done
           complete = false
           break
        end     
    end
    
    return complete
  end
 
 
  def display_as_complete?(user)  
    not_corresponding = self.corresponding_author != user  
    return  (self.committed or not_corresponding) #&& (!provisionally_accepted || self.resubmitted?)
  end
  
  
 
  def resubmitted?
    sub_date = self.time_of_status(ArticleSubmission::SUBMITTED)
    prov_date = self.time_of_status(ArticleSubmission::PROVISIONALLY_ACCEPTED)
    unless sub_date.blank? && prov_date.blank?
      return sub_date > prov_date
    else
      return false
    end
    
  end
  
  def provisionally_accepted
   self.has_had_status?(ArticleSubmission::PROVISIONALLY_ACCEPTED)
  end
  
  # Check this ArticleSubmission for problems, returning a list of problems or nil if none found
  def problems(current_user=nil)
    user = current_user || self.corresponding_author

    list = []
    
    page_valid?(:general)    or list << 'Complete the General Info page.'
    page_valid?(:coauthors)  or list << 'Complete the Co-Authors page.'
    page_valid?(:reviewers)  or list << 'Complete the Reviewers page.'
    page_valid?(:fees)       or list << 'Complete the Fees page.'
    page_valid?(:checklist)  or list << 'Complete the Checklist page.'
    page_valid?(:review)     or list << 'Complete the Review page.'
    completed_coi?(user)     or list << 'Complete the Financial Disclosure form.'
    coauthors_valid? or list << 'You specified that you are not the sole author of this manuscript. Please add the coauthor(s)'
    ca_contribution = Contribution.find_by_article_submission_and_user(self.id, user.id)
    ca_contribution.responsibilities_sig_assent or list << 'Complete the Author Responsibilities Form.'
    ca_contribution.copyright_sig_assent or list << 'Complete the Copyright Assignment Form.'
    
    unless(self.isVideo?)
      self.manuscript or list << 'Upload your manuscript.'
      self.cover_letter or list << 'Upload your cover letter.'
      if self.provisionally_accepted
        self.has_had_status?(ArticleSubmission::MANUSCRIPT_RESUBMITTED) or list << "Resubmit your manuscript"
        self.has_had_status?(ArticleSubmission::COVER_LETTER_RESUBMITTED) or list << "Resubmit your cover letter"
            
      end
    else
      !self.manuscript_video_link.blank? or list << 'Upload Video Link'
    end
    list.compact!
    
    (list.length > 0) ? list : nil
  end
  
  
  def coauthors_valid?
    
    return self.sole_author || (!self.sole_author && self.coauthors.size > 0)
    
  end

  def page_valid?(form_state)
    current_form_state = self.form_state
    self.form_state = form_state
    is_valid = valid?
    self.form_state = current_form_state
    return is_valid
  end

  # Return true if the given user has completed their COI for any version of this manuscript
  # The user defaults to the corresponding author, if not given
  def completed_coi?(current_user = nil)
    user = current_user || self.corresponding_author

    coi = latest_manuscript_coi_form_by_user_id(user.id)
    if coi and coi.committed
      return true
    else
      return false
    end
  end
  
  def article_submission_review_by_user_id(user)   
     as =  ArticleSubmissionReviewer.find(:first,:conditions=>{:article_submission_id=>self.id,:user_id=>user.id})   
     return as
  end
  
  
  def contribution_by_user_id(user_id)
    # The contribution that belongs to this user for this article_submission is the intersection of the 2 sets
    possible_contributions = User.find(user_id).contributions & self.contributions
    
    # something is wrong if we have no possible contributions, was supposed to be created when we created this article_submission
    if possible_contributions.empty?
      logger.info("Something is wrong, I could not find a contribution for this article_submission")
      return nil
    elsif possible_contributions.length > 1
      logger.info("Something is wrong, I found more than 1 contribution for this user / article_submission pair")
      return nil
    end
    
    possible_contributions[0]
  end
  
  def pf_status_from_current_status
    curr_stat = self.current_status
    article_status = ArticleStatus.find_by_name(curr_stat.name)
    return article_status
  end
  
  def current_status_from_pf_status 
    status = nil
    if(self.article)
      article_status = self.article.article_status
      entity = Entity.find_by_entity_type('article_submission')
      status = Status.find(:first,:conditions=>{:name=>article_status.status,:entity_id=>entity.id}) if article_status
    end
    return status
  end
  
  
  def set_current_status_from_pf_status 
    status = current_status_from_pf_status 
    self.change_status(status.key) if status
  end
  
  
  # Import title, status = 'Forms Received', submitted = submission1 as a new article
  def import_to_pf
    begin
      Configuration.advance_manuscript_sequence
      self.create_article(:title => self.title, 
                          :article_status_id => 4, 
                          :date_submission_1 => self.committed,
                          :manuscript_num => Configuration.get_value("manuscript_sequence"))
      self.imported_to_pf = Date.today
      self.save(false)
      article = self.article
      article.article_sections << ArticleSection.find(self.article_section_id)
      self.coauthors.each do |ca|
        article.role_instances << RoleInstance.new(:user_id => ca.id, :role_id => 2)
      end
      article.role_instances << RoleInstance.new(:user_id => self.corresponding_author.id, :role_id => 1)
      article.create_date = Time.now
      article.save!
      self.change_status(ArticleSubmission::FORMS_RECIEVED)
    rescue
      logger.info("**** Couldn't import to pubforecaster: #{$!}")
      false
    end
  end


  def do_pub_charge
    raise StandardError, "Must save record first" if self.new_record?
    if self.pub_charge and self.pub_charge.processed
      raise StandardError, "This charge has already been processed on: #{self.pub_charge.processed}"
    end

    #logger.info("*** finding or creating pub charge")
    unless self.pub_charge
      #logger.info("*** Creating a new pub_charge ***")
      self.pub_charge = Charge.new(:charge_type_id => ChargeType.find(2).id)
    end

    #logger.info("*** processing charge.. new_record? (#{self.pub_charge.new_record?})")
    self.pub_charge.process!
    #logger.info("*** processed... charge: #{self.pub_charge.inspect}")

    self.pub_charge.settled?
  end


  def do_initial_charge
    raise StandardError, "Must save record first" if self.new_record?
    if self.initial_charge and self.initial_charge.processed
      raise StandardError, "This charge has already been processed on: #{self.initial_charge.processed}"
    end

    #logger.info("*** finding or creating initial charge")
    unless self.initial_charge 
      #logger.info("*** Creating a new initial_charge ***")
      self.initial_charge = Charge.new(:charge_type_id => ChargeType.find(1).id)
    end

    #logger.info("*** processing charge.. new_record? (#{self.initial_charge.new_record?})")
    self.initial_charge.process!
    #logger.info("*** processed... charge: #{self.initial_charge.inspect}")

    self.initial_charge.settled?
  end
  
  def credit_card
    self.corresponding_author.credit_card
  end  
 
  def pub_charge_processed
    self.pub_charge ? self.pub_charge.processed : nil
  end
 
  def initial_charge_processed
    self.initial_charge ? self.initial_charge.processed : nil
  end


  def notify_coauthors_of_coi
    #begin
      coauthor_contributions.each do |contribution|
        Notifier.deliver_manuscript_coi_link(contribution)
      end
    #rescue
    #  logger.info("Couldn't notify coauthors of coi... #{$!}")
    #  return false
    #end
  end

  def save_reviewers(ids=[])
      revs = reviewers
      delete_list = Array.new
      revs.each do|s|
        if(!ids.include?s.id.to_s)
          delete_list << s
        else
          ids.delete((s.id).to_s)
         end
      end   
    
      delete_list.each do|i|
        #revs.delete(i) don't need to do this. was causing a bug
        ids.delete i.id
      end
      
      ids.each do |id|
        revs << User.find(id) 
      end  
      return nil
  end
   
   def manuscript
     return self.manuscripts.last
   end
   
   def cover_letter
     return self.cover_letters.last
   end
   
   def hiding_original_file_or_files?(type)
      file_or_files = self.send(type)
      unless(file_or_files.instance_of?Array)
           return file_or_files.nil? || (self.provisionally_accepted && file_or_files.version == 1)
      else
           file_or_files = file_or_files.sort_by(&:version)
           return file_or_files.empty? || (self.provisionally_accepted && file_or_files.last.version==1)
      end
   end
   
   def additional_files_to_show
     files = self.additional_files
     return files if files.empty?
     current_version = files.sort_by(&:version).last.version
     return files.select{|f|f.version==current_version}
   end
   
   
   def permission
     return self.permissions.last
   end
   
   def isVideo?
     if self.manuscript_type
      return self.manuscript_type.name == "Video"
    else
      return false
    end
  end
  
  def faux_delete(admin=false)
       status = admin ? ArticleSubmission::ADMIN_REMOVED : ArticleSubmission::REMOVED
       self.change_status(status)
       self.update_attribute(:last_revision,false)
       sibs = self.siblings
       sibs = sibs.sort_by{|s|s.id}
       sibs.last.update_attribute(:last_revision,true)       
  end

  # Return true if the manuscript has been removed by the admin or author
  def is_removed?
    self.has_current_status_of?(ArticleSubmission::ADMIN_REMOVED) || self.has_current_status_of?(ArticleSubmission::REMOVED)
  end

  # Depreciated, as we don't use camel case in method names
  def isRemoved?
    is_removed?
  end

  # Increments the manuscript number of the associated article to the next revision
  def increment_manuscript_rev_num
    if self.version && self.article
      num = self.manuscript_number 
      rev = num.scan(/\.R\d+/)[0]
      if rev
        num.gsub!(/\.R\d+/,"")
        rev_num = rev.gsub(/\.R/,"")
        rev_num = rev_num.to_i
        num+=".R#{rev_num+1}"
      else
        num = "#{num}.R1"
      end    
        self.article.update_attribute(:manuscript_num,num)
    end
  end

 
  # Returns the manuscript number (a STRING) of the associated article, or the string 'No Manuscript Number' 
  def manuscript_number
    if self.article
      return self.article.manuscript_num.blank? ?  "No Manuscript Number" :  self.article.manuscript_num  
    else   
      return "No Manuscript Number"
    end 
  end

  # Gives the contributions that have no committeed coi forms
  def contributions_with_outstanding_cois
    self.contributions.reject {|c| c.latest_committed_manuscript_coi_form }
  end

  def section_editors_potential_coi_info
    section_editors.collect do |user|
      user.potential_coi_info
    end.join("<br/>")
  end

  def section_editors
    self.article_section.users.select {|u| u.has_role?('editor')}
  end

  # Reassign the user which has the corresponding author role for this submission
  # If the corresponding author role does not exist, then create one, and assign it
  #
  # user = the User to assign
  def corresponding_author=(user)
    contribution = self.corresponding_author_contribution || Contribution.new(:role_id => 1)
    contribution.user_id = user.id
    contribution.save(false)
    self.corresponding_author 
  end
  

  def reviewable?
    return !self.committed.nil? && !self.article.nil?
  end
  
  def parent
     self.article_submission || self
  end
  
  # Return the Original Article Submission / Super Parent of this article submission
  # This is denoted by an article submission with a parent_id of nil, also the version should be 0
  def first_submission
    as = as.parent
  end

  # Returns 1 string 'Corresponding Author', 'Coauthor', 'Reviewer', or 'Section Editor' for an article submission, with that priority
  def users_role_with_this_submission(user)
    if self.corresponding_author == user
      return 'Corresponding Author'
    elsif self.coauthors.include?(user)
      return 'Coauthor'
    elsif self.reviewers.include?(user)
      return 'Reviewer'
    elsif section_editors.include?(user)
      return 'Section Editor'
    else
      return 'This user is not associated with this manuscript'
    end 
  end

  # Returns a STRING, identifying the current version
  # Versions start at 1 - Original Submission has version 1
  def version_name
    if self.version.nil?
      'First Submission'
    else
      "#{self.version.ordinalize}"
    end
  end
  
   # Returns the number of days since this manuscript version was submitted
   # TODO: Should we make this account for all versions? (AMA - 12 Nov 2010)
   def days_since_committed
     if first_submission.committed
       ((Time.now - first_submission.committed)/86400).to_i
     else
       nil
     end
 end

  ## HACK TO LET US COMMIT A CHANGE... DONT CARRY FORWARD TO NEXT DEPLOY - AMA - 12 Nove 2010
  #def parent_id
  #  nil
  #end

  #####################################################################################
 
 
  private

  def yes_or_no(state)
    state ? "Yes" : "No"
  end


  ## These states are used for validation, to only validate aspects of this object only when we are on certain pages,
  ## represented by 'states'  
  def fees_state?
    self.form_state == :fees
  end
  def fees_state_and_invited_set?
    fees_state? && !self.invited.blank?
  end
  def fees_state_and_invited?
    fees_state? and self.invited
  end
  def fees_state_and_need_to_pay?
    fees_state? and !self.invited.nil? and self.invited == false and !self.is_letter.nil? && self.is_letter == false
  end
  def fees_state_and_need_to_pay_and_not_exempt?
    fees_state_and_need_to_pay? and self.payment_type != 'exempt'
  end
  
  # fees_state_and_not_invited_and_not_exempt?
  
  def fees_state_and_can_pay?
    fees_state_and_need_to_pay? and self.fees_pubfee_status != 'cant_pay'
  end
  
  def fees_state_and_credit?
    fees_state? and self.payment_type == 'credit' and fees_state_and_need_to_pay_and_not_exempt?
  end
  def fees_state_and_cant_pay?
    fees_state? and self.fees_pubfee_status == 'cant_pay' and fees_state_and_need_to_pay_and_not_exempt?
  end
  
  def checklist_state?
   self.form_state == :checklist
  end
 
  def update_create_audit_trail
    self.create_date = Time.now
  end

  def update_save_audit_trail
    self.mod_date = Time.now
  end
  
 
 
end
