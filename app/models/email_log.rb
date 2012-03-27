class EmailLog < ActiveRecord::Base


################################ CONSTANTS #################################

SENT_REVIEWER_COI_REMINDER = "reviewer_coi_reminder"
SENT_AUTHOR_COI_REMINDER = "author_coi_reminder"
SENT_AUTHOR_COI_REMINDER_FROM_AUTHOR = "author_coi_reminder_from_author"
SENT_AUTHOR_COI_REMINDER_INITIAL = "author_coi_reminder_initial"
SENT_BLANKET_COI_REMINDER = "blanket_coi_reminder"
SENT_REVIEWER_INVITE = "reviewer_invite_link"
SENT_REVIEWER_PACKET = "reviewer_packet"
SENT_REVIEWER_CHECK_IN = "reviewer_check_in"
SENT_REVIEWER_FIRST_REMINDER = "reviewer_first_reminder"
SENT_REVIEWER_SECOND_REMINDER = "reviewer_second_reminder"
SENT_REVIEWER_URGENT_NOTIFICATION = "reviewer_urgent_notification"
SENT_REVIEWER_THANKS_BUT_NOT_ABLE = "reviewer_thanks_unable"
SENT_REVIEWER_THANKS_BUT_NOT_ABLE_WITH_ALTERNATE = "reviewer_thanks_unable_alternate"
SENT_COI_NOTICE = "sent_coi_notices"
SENT_REVIEWER_COMMENTS_REPORT = "reviewer_comments_report"
SENT_MANUSCRIPT_SUBMISSION_NOTICE = "manuscript_submission_notice"
SENT_REVIEWER_INVITE_LINK = "reviewer_invite_link"
NOTIFIY_FAILED_CREDIT_CARD = "notify_failed_credit_card"
SENT_MANUSCRIPT_FILES = "manuscript_files"
SENT_PAYMENT_INFO = "payment_info"
SENT_RESET_PASSWORD_LINK = "reset_password_link"
SENT_MANUSCRIPT_COI_LINK = "manuscript_coi_link"
SENT_CUSTOM_MANUSCRIPT_COI_LINK = "custom_manuscript_coi_link"
SENT_BLANKET_COI_LINK = "blanket_coi_link"
SENT_MANUSCRIPT_COI_NOTICE = "manuscript_coi_notice"
SENT_GENERIC_EMAIL = "generic_email"
SENT_PROCESS_PUB_CHARGE_REMINDER = "process_pub_charge_reminder"


################################ DB Associations ##########################

belongs_to :user,:foreign_key => "recipient_user_id"


  ######  FIXES  ######
  # Assign the 'reset_password_request' category to the email logs if they have in the subject 'password'
  def self.category_assign_password_reset_request
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject && el.subject.include?('password')}.collect {|el| el.update_attribute(:category, 'reset_password_request')}
  end

  # Assign the 'send_submission_files' category to all email logs that were emails sending files upon submission
  def self.category_assign_send_submission_files
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject && el.subject.include?('] Files')}.collect {|el| el.update_attribute(:category, 'send_submission_files')}
  end

  # Assign the 'coi_notice' category to all emails with subjects 'Thank you for updating your Financial Disclosure'
  def self.category_assign_coi_notice
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject? && el.subject.include?('Thank you for updating')}.collect{|el| el.update_attribute(:category, 'coi_notice')}
  end

  # Assign the 'coi_link' category to all emails with subjects 'Your online Financial'
  def self.category_assign_coi_link
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject? && el.subject.include?('Your online Financial')}.collect{|el| el.update_attribute(:category, 'coi_link')}
  end

  # Assign the 'reviewer_suggestion_thank_you' to all emails with subjects 'Thank you for your suggestion
  def self.category_assign_reviewer_suggestion_thank_you
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject? && el.subject.include?('Thank you for your suggestion')}.collect{|el| el.update_attribute(:category, 'reviewer_suggestion_thank_you')}
  end

  # Assign the 'thank_you_for_reviewing' to all emails with the subjects 'Thank You For Reviewing'
  def self.category_assign_thank_you_for_reviewing
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject? && el.subject.include?('Thank You For Reviewing')}.collect{|el| el.update_attribute(:category, 'thank_you_for_reviewing')}
  end

  # Assign the 'reviewer_invite_link' to all emails with the subjects: 'Urgent: Request to Review
  def self.category_assign_reviewer_request_to_review
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject? && el.subject.include?('Urgent: Request to Review')}.collect{|el| el.update_attribute(:category, 'reviewer_invite_link')}
  end

  # Assign teh 'reviewer_packet' category to all emails with the subjects: 'Reviewer Packet'
  def self.category_assign_reviewer_packet
    self.find(:all, :conditions => {:category => nil}).select {|el| el.subject? && el.subject.include?('Reviewer Packet')}.collect{|el| el.update_attribute(:category, 'reviewer_packet')}
  end


end
