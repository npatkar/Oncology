class Notifier < ActionMailer::Base

  def test_email
    set_params
    recipients   App::Config.submissions_email
    subject "Test of the manuscript submissions email system"
    body 
  end

  def reviewer_comments_report comments
    set_params
    recipients App::Config.managing_editor_email
    subject "Reviewer Comments Report for #{comments.article_submission.title}"
    @message = UserTemplate.get_template("reviewer_comments_report", comments) 
    body :message=>@message
  end


  def manuscript_submission_notice(article_submission)
    set_params
    ca = article_submission.corresponding_author    
    recipients    user_to_email(ca)
    bcc  App::Config.submissions_email   
    subject "[#{article_submission.title}] #{ca.full_name}, Your submission has been received for The Oncologist"
    body :article_submission=>article_submission
  end
 
 
  def reviewer_invite_link(message,article_submission_reviewer)
    reviewer = article_submission_reviewer.user
    corresponding_author = article_submission_reviewer.article_submission.corresponding_author
    set_params
    recipients   user_to_email(reviewer)
    bcc  App::Config.submissions_email   
    subject "Urgent: Request to Review from The Oncologist (#{corresponding_author.full_name})"   
    @message = message
    log_email(reviewer)
    body :message=>message
  end


  def notify_failed_credit_card(charge)
    set_params  
    recipients    [App::Config.finance_email]
    bcc  App::Config.submissions_email   
    subject "Failed Credit Card Transaction: [#{charge.user_name}"
    log_email(charge.article_submission.corresponding_author)
    body :charge => charge
  end
  

  def process_pub_charge_reminder(article_submission,values_hash=Hash.new)
    set_params
    ca = article_submission.corresponding_author   
    recipients    App::Config.finance_email
    bcc  App::Config.submissions_email    
    subject "Process publication fee for: [#{article_submission.title}] #{ca.full_name}"
    values_hash.merge!(message_params(user))
    body :article_submission=>article_submission
  end

  def manuscript_files(article_submission)
    set_params 
    recipients  App::Config.submissions_email
    subject "[#{article_submission.title}] Files"
    @message = "#{article_submission.title} files"
    log_email(nil)
    body :article_submission=>article_submission
  end




  def payment_info(article_submission)
    set_params
    ca = article_submission.corresponding_author
    recipients  App::Config.finance_email
    subject "[#{article_submission.title}] #{ca.full_name}, Payment Info"
    @message = UserTemplate.get_template('payment_info', @article_submission)  
    log_email(ca)
    body :article_submission=>article_submission
  end




  def reset_password_link(user)
    set_params
    recipients    user_to_email(user)
    subject "Reset password request for: #{user.name}"
    @message = UserTemplate.get_template('reset_password', @user)
    log_email(user)
    body :user=>user
  end




  def manuscript_coi_link(parent,values_hash)
    set_params
    user = parent.user  
    recipients   [user_to_email(user)]
    subject "[#{parent.article_submission.title}] Your online Financial Disclosure form for The Oncologist"
    @message = UserTemplate.get_template('manuscript_coi_link', parent)
    body :parent=>parent
    values_hash.merge!(message_params(user))
  end
  
  def custom_manuscript_coi_link(parent,values_hash,message)
    set_params
    user = parent.user  
    recipients   [user_to_email(user)]
    subject "[#{parent.article_submission.title}] Your online Financial Disclosure form for The Oncologist"
    body :message=>message
    values_hash.merge!(message_params(user))
  end
  
  
  def blanket_coi_link(user,values_hash)
    set_params
    recipients   [user_to_email(user)]  
    subject "Please update your Financial Disclosure form online."
    body :user=>user
    values_hash.merge!(message_params(user))
    logger.info("**********#{values_hash.inspect}")
  end
  


  def manuscript_coi_notice(manuscript_coi_form)
    set_params
    contribution = manuscript_coi_form.contribution
    @recipients = [user_to_email(manuscript_coi_form.user)]
    @copy = [App::Config.submissions_email]
    if manuscript_coi_form.user.email != manuscript_coi_form.corresponding_author.email
      @copy << user_to_email(manuscript_coi_form.corresponding_author)
    end 
    recipients @recipients
    bcc @copy
    subject "[#{contribution.article_submission.title}] Thank you for updating your Financial Disclosure form"
   
    body :contribution=>contribution
  end
 
 
  
  def blanket_coi_notice(user)
    set_params
    recipients [user_to_email(user)]
    @copy = [App::Config.submissions_email]
    from   App::Config.managing_editor_email
    bcc @copy
    subject "Thank you for updating your Financial Disclosure form"
    body :user=>user
  end



  def cadmus_error(log)
    set_params
    recipients = App::Config.cadmus_error_email
                 
    subject "Submission Packet for #{log.article_submission.title} having id of #{log.article_submission.id} Failed"
    body :log=>log
  end
  
  def generic_email(user,values_hash,message)
    set_params
    recipients [user_to_email(user)]
    from   App::Config.managing_editor_email
    subject "Important Message From The Oncologist"
    @message = message
    body :message=>@message
    values_hash.merge!(message_params(user))
  end
  
protected

  def log_email(user,category=nil)   
    log = EmailLog.create(message_params(user))  
   
  end

   def message_params(user)
    id = user ? user.id : nil
    return {:content=>@message,:recipient=>@recipients,:sender=>@from,:subject=>@subject,:recipient_user_id=>id}
   end

  def set_params(options={})
    from          App::Config.from_email
    headers       "Reply-to" => App::Config.from_email
    sent_on       Time.now
    content_type  "text/html"
  end
  
  def user_to_email(user)
    unless user.supress_email
    #return  RAILS_ENV == "production" ? "#{user.full_name.strip} <#{user.email.strip}>" : App::Config.test_email
      "#{user.full_name.strip} <#{user.email.strip}>"
    else
    return ""
    end
  end
end
