require 'digest/sha1'

class Contribution < ActiveRecord::Base

  attr_accessor :form_state
  
  # Table Relationships
  belongs_to :article_submission
  belongs_to :user
  belongs_to :role
  belongs_to :responsibilities_pdf, 
             :dependent => :destroy, 
             :class_name => 'Pdf'
  belongs_to :copyright_pdf, 
	     :dependent => :destroy, 
             :class_name => 'Pdf'

  include EmailableMixin
  has_and_belongs_to_many :contribution_types
  
  has_many :manuscript_coi_forms, 
           :dependent => :destroy

  
  # Triggers
  before_create :init_coi_token
  before_validation :sanitize_data
  
  
  
  ## Validations

  # Validations to run on the Author Responsibilities page
  validates_inclusion_of :agree_contents,   :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'
  # This is a checkbox, no validation necessary anymore
  #validates_inclusion_of :sole_submission,  :in => [true, false], :if => :author_resp_state_and_assisted?, :message=>'has not been answered'
  validates_inclusion_of :received_payment, :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'
  # It's a checkbox now, but we don't accept the unchecked state

  validates_inclusion_of :tobacco,          :in => [true], :if => :author_resp_state?, :message=>'The Oncologist does not consider submissions from authors whose work was supported by tobacco funding.'
  validates_inclusion_of :published_elsewhere, :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'
  validates_inclusion_of :dna_research, :in => [true, false],     :if => :author_resp_state?, :message=>'has not been answered'
  validates_inclusion_of :human_experiment, :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'
  validates_inclusion_of :clintrials, :in => [true, false],       :if => :author_resp_state?, :message=>'has not been answered'
  validates_inclusion_of :consort_guidelines, :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'
  validates_inclusion_of :proprietary_guidelines, :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'
  validates_inclusion_of :agree_policies, :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'

  # Medical writer questions
  validates_inclusion_of :assisted,         :in => [true, false], :if => :author_resp_state?, :message=>'has not been answered'
  (1..6).each do |n|
    validates_inclusion_of "arynq#{n}", :in => [true, false], :if => :author_resp_state_and_assisted?, :message=>'has not been answered'
  end
  validates_inclusion_of "arynq7", :in => [true], :if => :author_resp_state?, :message=>'must be answered "Yes"'
  # The only generic medical writer question that needs details
  validates_presence_of "arynq2_details", :if => :author_resp_state_and_assisted_and_not_arynq2?, :message=>'has not been explained'
 
  validates_presence_of :assisted_details,        :if => :author_resp_state_and_assisted?
  validates_presence_of :agree_contents_details,  :if => :author_resp_state_and_not_agree_contents?
  # No more details collected
  #validates_presence_of :sole_submission_details, :if => :author_resp_state_and_not_sole_submission?
  validates_presence_of :received_payment_details, :if => :author_resp_state_and_received_payment?
  # No more details collected
  # validates_presence_of :tobacco_details,         :if => :author_resp_state_and_tobacco?
  validates_presence_of :proprietary_guidelines_details, :if => :author_resp_state_and_not_proprietary_guidelines?
  validates_presence_of :agree_policies_details,  :if => :author_resp_state_and_not_agree_policies?


  validates_presence_of :responsibilities_sig_completed_by, :if => :author_resp_state?
  validates_acceptance_of :responsibilities_sig_assent, :accept=>true,  :if => :author_resp_state?
 
 
  # Validations to run on the Copyright Assignment page
  validates_presence_of :copyright_sig_completed_by, :if => :copyright_state?
  validates_acceptance_of :copyright_sig_assent, :accept=>true, :if => :copyright_state?
  

  # Human name overrides of default rails .humanize of column name. Helps us have more friendly error-messages 
  attr_human_name :assisted => 'Assisted',
                  :agree_contents => 'Authors in Agreement',
                  :sole_submission => 'Submitted only to Oncologist',
                  :received_payment => 'Received Payment',
                  :tobacco => '',
                  :published_elsewhere => 'Indicated if Published Elsewhere',
                  :dna_research => 'Description of Procedures if DNA Research',
                  :human_experiment => 'Reports on Human Experimentation',
                  :clintrials => 'Registered Clinical Trials',
                  :consort_guidelines => 'CONSORT compliance',
                  :proprietary_guidelines => 'Agreed to Proprietary Guidelines',
                  :agree_policies => 'Agree to Journal Policies',
                  :arynq1 => '"Does the medical writer meet the three..."',
                  :arynq2 => '"If not, has the writer been identified.."',
                  :arynq2_details => '"Has the writer been identified.."',
                  :arynq3 => '"Source of funding been identified..."',
                  :arynq4 => '"Did the author(s) make the final decision on the main..."',
                  :arynq5 => '"Did the author(s) make the final decision on the primary..."',
                  :arynq6 => '"Can the medical writer provide evidence..."',
                  :arynq7 => '"I represent to AlphaMed Press that i have obtained..."',
                                  
                  :responsibilities_sig_completed_by => 'Completed By',
                  :responsibilities_sig_entity_title => 'Name of Organization/Institution and Your Title',
                  :responsibilities_sig_entity => 'Name of Organization/Institution',
                  :responsibilities_sig_assent => 'The terms of this agreement',
                  
                  :copyright_sig_completed_by => 'Completed By Name',
                  :copyright_sig_entity_title => 'Name of Organization/Institution and Your Title',
                  :copyright_sig_entity => 'Name of Organization/Institution',
                  :copyright_sig_assent => 'The terms of this agreement'
                  
  
  
  def self.find_by_article_submission_and_user(article_submission_id, user_id)
    if (c = Contribution.find_by_sql("SELECT contributions.*
      FROM contributions 
      INNER JOIN article_submissions ON contributions.article_submission_id = article_submissions.id
      WHERE user_id = #{user_id} AND article_submission_id = #{article_submission_id}"))
      
      return c[0]
    else
      return nil
    end
  end
  
  def latest_manuscript_coi_form
    conditions = 1
    order = "version DESC"
    get_coi_form_from_sibs(conditions,order)
  end
  
  def latest_committed_manuscript_coi_form
    conditions = "committed IS NOT NULL"
    order = "version DESC"
    get_coi_form_from_sibs(conditions,order)    
  end
  
  def latest_uncommitted_manuscript_coi_form
    conditions = "committed IS NULL"
    order = "version DESC"
    get_coi_form_from_sibs(conditions,order)
  end
 
   
  def get_coi_form_from_sibs(conditions,order)
    sibs = self.sibling_contributions
    manuscripts = Array.new
    if sibs.empty?
      return self.manuscript_coi_forms.find(:first, :conditions => conditions, :order => order)
    else
      sibs.each do |a|
        latest = a.manuscript_coi_forms.find(:first, :conditions => conditions, :order => order)
        manuscripts << latest unless latest.nil?
      end
      manuscripts = manuscripts.sort_by{ |m| m.id} 
      return manuscripts.last
    end
  end

  # Returns an array of contributions from all article submissions belonging to this parent 
  # FIXED: 18-Nov-2010 WAS RETURNING AN ARTICLE SUBMISSION ON SINGLE SUBMISSION
  def sibling_contributions
    contrs = Array.new
    
    unless self.article_submission.is_original?
      self.article_submission.siblings.each do |as|
        contr = Contribution.find_by_article_submission_and_user(as.id, self.user.id)
        contrs << contr unless contr.nil? 
      end
    else
      contrs << self
    end 
    return contrs
  end
  

  
  # We use this token to log in directly to the system, filling out a COI form
  def init_coi_token
    self.coi_token = Digest::SHA1.hexdigest(Time.now.to_s)
  end
  
  #shortcut set up for the email templates var_merge feature (so we can get the full name of the CA with only 2 method calls)
  def corresponding_author
    self.article_submission.corresponding_author
  end
  
  def corresponding_author?
    self.user.id == self.corresponding_author.id
  end
  def email_sent_at(category)
    emails = self.email_logs.select{|e|e.category==category}
    dates = emails.collect{|e|e.created_at}
    return dates.sort.last 
  end
  
  # Give status, in form of a text message, of COI form for specified article_submission
  def manuscript_coi_status()
    manuscript_coi_form = latest_manuscript_coi_form
    if manuscript_coi_form and manuscript_coi_form.committed
      return "Complete #: " + manuscript_coi_form.sig_time.strftime("%x")
    end
    return nil
  end
  
  def coi_info
      hash = Hash.new
      coi = self.latest_committed_manuscript_coi_form
      if coi
        if coi.conflicts or coi.alternative_use or coi.employment or coi.ip or coi.consultant or coi.honoraria or coi.research or coi.ownership or coi.expert or coi.other         
           hash["Alternative Use"] = coi.alternative_use_details  if  coi.alternative_use
          if coi.conflicts
            ['employment', 'ip', 'consultant', 'honoraria', 'research', 'ownership', 'expert', 'other'].each do |t|      
                hash[t.humanize] = coi.send(t + "_details") if coi.send(t)
            end
          end
        else
          hash["No Reported Conflicts"] = ""
        end 
      else
        hash["Coi Form Is Outstanding"] = ""
      end
  
     return hash
  end
  
  
  def forms_complete?
    return self.latest_committed_manuscript_coi_form && self.copyright_status()
  end
  
  
  def copyright_status()
    return form_status('copyright_sig_time')
  end

  def responsibilities_status()
    return form_status('responsibilities_sig_time')
  end

  def form_status(field)
    date = self.send(field)
    if date
      return "Complete" #completed: " + date.strftime('%x')
    else
      return nil
    end
  end
 
  def manuscript_coi_link
    "/manuscript_coi_forms/init?contribution_id=#{self.id}"
  end 
  
  # Give details on state of 'state'
  def details_on(show_state, field)
    answer = self.send(field.to_s) ? 'Yes' : 'No'
    if self.send(field.to_s) == show_state
      "#{answer}; #{self.send(field.to_s + "_details")}"
    else
      answer
    end
  end 
  
  
  def author_resp_info
    out = <<HERE
  The authors were assisted by a contracted technical-medical writer or editor in the preparation of this manuscript: #{details_on(true, 'assisted')}
  All authors are in complete agreement with the contents of this manuscript: #{details_on(false, 'agree_contents')}
  This manuscript currently being submitted only to The Oncologist: #{self.sole_submission}
  One or more of the authors received payment or other compensation for writing this article: #{details_on(false, 'received_payment')}
  This manuscript was funded by the tobacco industry or a foundation funded by the tobacco industry: #{self.tobacco}
  Portions of this study that were published elsewhere are so indicated in the text and references. Permissions that were obtained for figures, tables, etc. that have been produced or adapted from another publication have all corresponding documentation included with submission: #{yes_or_no(self.published_elsewhere)}
  If the manuscript deals with recombinant DNA research, a description has been included of the procedures practiced, which follows the National Institutes of Health guidelines: #{yes_or_no(self.human_experiment)}
  All clinical trials are registered in a public trials registry approved by the ICMJE website (http://www.icmje.org) as fully compliant with World Health Organizations minimal data set: #{yes_or_no(self.clintrials)}
  Authors have complied with published CONSORT guidelines (http://www.consort-statement.org/). The checklist is being submitted to AlphaMed Press along with the manuscript; the recommended trial flow diagram is presented as a figure: #{yes_or_no(self.consort_guidelines)}
  I have read, agreed to, and followed the policies on proprietary drug names and proprietary devices, as explained in the Information for Authors (available online at http://theoncologist.alphamedpress.org/misc/TO_Info4Authors.pdf): #{details_on(false, 'proprietary_guidelines')}
  The authors agree to abide by the policies of this Journal: #{details_on(false, 'agree_policies')}
HERE
  out
  end

  def assistedinfo
    self.assisted ? 'Assisted' : 'Not assisted'
  end
  
  def solesubmissioninfo
    # The old logic says they didn't have to answer this question if weren't 'assisted', now they answer it all the time
    #if self.assisted
      self.sole_submission ? 'Not submitted elsewhere' : 'Submitted Elsewhere'
    #else
    #  'Not asked'
    #end
  end
  
  # Give details on state of 'state'
  def details_on(show_state, field)
    answer = self.send(field.to_s) ? 'Yes' : 'No'
    if self.send(field.to_s) and  show_state
      "#{self.send(field.to_s + "_details")}"
    elsif ! self.send(field.to_s) and !  show_state
            "#{self.send(field.to_s + "_details")}"
    else
      ''
    end
  end  
  
  def coi_auto_sign_in_url
    self.user.generic_auto_sign_in_url("manuscript_coi_forms/init?contribution_id=#{self.id}")
  end

  def coi_auto_sign_in_address
    self.user.generic_auto_sign_in_address("manuscript_coi_forms/init?contribution_id=#{self.id}")
  end

  ######################################################################################
  
  private

  def sanitize_data
    if author_resp_state?
      # None of these questions are to be answered unless assisted is true
      unless self.assisted
       # [:agree_contents, :sole_submission, :received_payment, :tobacco, :published_elsewhere, :dna_research, 
       #  :human_experiment, :clintrials, :consort_guidelines, :proprietary_guidelines, :agree_policies, :assisted_details,
       #  :agree_contents_details, :received_payment_details,  
       #  :proprietary_guidelines_details, :agree_policies_details].each do |field|
        [:assisted_details].each do |field|
          self.update_attribute(field.to_s, nil)
        end
        [1,2,3,4,5,6].each do |n|
          self.update_attribute("arynq#{n}", nil)
          self.update_attribute("arynq#{n}_details", nil)
        end
      end
    end
  end
  
  def author_resp_state?
    self.form_state == :author_resp
  end
  def author_resp_state_and_assisted?
    author_resp_state? and self.assisted
  end
  def author_resp_state_and_not_agree_contents?
   author_resp_state? and ! self.agree_contents.nil? and ! self.agree_contents
  end
  def author_resp_state_and_not_sole_submission?
   author_resp_state? and self.sole_submission.nil? and self.sole_submission
  end
  def author_resp_state_and_received_payment?
   author_resp_state? and self.received_payment
  end
  def author_resp_state_and_tobacco?
   author_resp_state? and self.tobacco
  end
  def author_resp_state_and_not_proprietary_guidelines?
   author_resp_state? and ! self.proprietary_guidelines.nil? and ! self.proprietary_guidelines
  end
  def author_resp_state_and_not_agree_policies?
   author_resp_state? and ! self.agree_policies.nil? and ! self.agree_policies
  end
  def author_resp_state_and_assisted_and_not_arynq2?
    author_resp_state? and self.assisted and ! self.arynq2
  end
  
  def copyright_state?
    self.form_state == :copyright
  end

end
