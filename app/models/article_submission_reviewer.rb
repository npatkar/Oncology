class ArticleSubmissionReviewer < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :article_submission
  has_many :manuscript_coi_forms,:dependent => :destroy
  belongs_to :alternate_reviewer,:class_name=>"User"
  has_one :reviewer_comment
  has_many :email_logs,:as=>:email_loggable,:dependent=>:delete_all
  #has_many :entity_statuses,:as=>:trackable,:dependent=>:delete_all
  SUBMITTED_COMMENTS = "reviewer_received_comments"
  NOT_YET_INVITED = "reviewer_not_yet_invited"

  include EntityMixin
  include EmailableMixin

  # Return true if we have an email log saying we sent an invitation to review, but no status awaiting review response
  def missing_entity_status_invitation?
    self.email_logs.find_by_category('reviewer_invite_link') && !self.entity_statuses.find_by_status_id(18)
  end

  # Fix an article_submission_reviewer that has an invitation email log but has no reviwer_awaiting_response status
  def fix_missing_entity_status_invitation
    if self.email_logs.find_by_category('reviewer_invite_link') && !self.entity_statuses.find_by_status_id(18)
      self.add_status('reviewer_invited_awaiting_response', self.email_logs.find_by_category('reviewer_invite_link').created_at)
    else
      logger.info("*** No need to fix article_submission_reviewer with id: #{self.id}.. looks good ***")
    end
  end
  
  #TODO DRY this up. duplice functionality in contributions
  def latest_manuscript_coi_form
    self.manuscript_coi_forms.find(:first, :order=>"version DESC")
  end
  
  def latest_committed_manuscript_coi_form
    self.manuscript_coi_forms.find(:first, :conditions=>"committed IS NOT NULL", :order=>"version DESC")
  end
  
  def latest_uncommitted_manuscript_coi_form
    self.manuscript_coi_forms.find(:first, :conditions=>"committed IS NULL", :order=>"version DESC")
  end
  
  def manuscript_coi_status
    manuscript_coi_form = latest_manuscript_coi_form
    if manuscript_coi_form and manuscript_coi_form.committed
      return "Complete #: " + manuscript_coi_form.sig_time.strftime("%x")
    end
    return nil
  end
  
  def reviewer
   return user  
  end

  def first_name
    return user.first_name
  end
 
  def last_name
    return user.last_name
  end
 
 
  def self.find_by_user_and_article_submission(user,as)
    return self.find(:first,:conditions=>{:user_id=>user.id,:article_submission_id=>as.id})  
  end
  
  def self.delete_by_user_and_article_submission(user_id,as_id)
     return self.delete_all(:user_id=>user_id,:article_submission_id=>as_id)  
  end
  
  def self.get_reviewer_list_with_status(status_key)
    #TODO improve this query. Over time it will probably get really slow
    @reviewers = self.find(:all)
    @reviewer_list = Array.new
    @reviewers.each do|rev|
      @reviewer_list <<rev if rev.current_status && rev.current_status.key == status_key
    end
    
    return @reviewer_list
  end
  
  
  def article
      return self.article_submission.article
  end

  def days_to_comment
    if self.current_status_key == 'reviewer_need_comments'
       if self.comments_deadline
        ((self.comments_deadline - Time.now)/86400).to_i
       else
         (((time_of_status(:reviewer_need_comments) + 10.days) - Time.now)/86400).to_i
       end
    else
      nil
    end
  end
 
 
  # Return the deadline for the needed comments.. calculated by adding 10 days to when they accepted to review
  # Return nil if no deadline is set due to not being in the correct status.
  # TODO: We need to put 10.days into a site-config table, user-configurable - AMA - 12 Nov 2010
  def comments_deadline
    if time_of_status(:reviewer_need_comments)
      self[:comments_deadline] || (time_of_status(:reviewer_need_comments) + 10.days)
    else
      nil
    end
  end
 
  def effective_comments_deadline
     val = self.comments_deadline || (time_of_status(:reviewer_need_comments) + 10.days)
     return val
  end
  

 
  def comments_overdue?
    if self.current_status_key == 'reviewer_need_comments' && days_to_comment < 0
      return true
    else
      return false
    end
  end 
  
  def role   
    return Role.find_by_key("reviewer")
  end
  
  def corresponding_author
    self.article_submission.corresponding_author
  end
  
  
  def self.num_not_reviewed(reviewer) 
    sql = <<-SQL
     select count(*) from entity_statuses es,statuses s,article_submission_reviewers ar
     where es.status_id = s.id and es.trackable_id = ar.id
     and es.trackable_type = "ArticleSubmissionReviewer"
     and (s.key = "reviewer_given_up" or s.key like "reviewer_declined%")
     and ar.user_id = #{reviewer.id}
    SQL
    return self.count_by_sql(sql)
  end
  
  def self.num_comments_submitted(reviewer)
    sql = <<-SQL
    select count(distinct s.name) from reviewer_comments rc,entity_statuses es,statuses s,
    article_submission_reviewers ar
    where es.status_id = s.id and es.trackable_id = rc.id
    and es.trackable_type = "ReviewerComment" and s.key = "reviewer_comments_submitted"
    and rc.article_submission_reviewer_id = ar.id
    and ar.user_id = #{reviewer.id}
    SQL
    
    return self.count_by_sql(sql)
  end
  
  def coi_auto_sign_in_url
    self.user.generic_auto_sign_in_url("manuscript_coi_forms/init?article_submission_reviewer_id=#{self.id}")
  end
  
  def coi_auto_sign_in_address
    self.user.generic_auto_sign_in_address("manuscript_coi_forms/init?article_submission_reviewer_id=#{self.id}")
  end

  def comments_auto_sign_in_url
    self.reviewer.generic_auto_sign_in_url("article_submission_reviewers/manuscript/#{self.id}")
  end

  def accept_invite_auto_sign_in_url
    self.reviewer.generic_auto_sign_in_url("article_submission_reviewers/accept_invite/#{self.id}")
  end
  def acceptinviteautosigninurl
    accept_invite_auto_sign_in_url
  end
end
