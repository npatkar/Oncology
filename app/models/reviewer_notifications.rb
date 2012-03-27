class ReviewerNotifications < ActionMailer::Base
  
  @@from_address = 'Nicole.Weber@TheOncologist.com'
  
  def manuscript_coi_link(a_s_r,values_hash)
    set_params
    article_submission = a_s_r.article_submission     
    recipients   user_to_email(a_s_r)
    subject "[#{article_submission.title}] Your online Financial Disclosure form for The Oncologist"
    @message = UserTemplate.get_template('reviewer_manuscript_coi_link', a_s_r)
    body :message=>@message
    values_hash.merge!(message_params(a_s_r.reviewer.id))
  end
  
    def custom_manuscript_coi_link(a_s_r,values_hash,message)
    set_params
    article_submission = a_s_r.article_submission     
    recipients   user_to_email(a_s_r)
    subject "[#{article_submission.title}] Your online Financial Disclosure form for The Oncologist"
    body :message=>message
    values_hash.merge!(message_params(a_s_r.reviewer.id))
  end
  
   def reviewer_invite_link(a_s_r,content,values_hash)
    corres_author = a_s_r.article_submission.corresponding_author
    set_params
    recipients   user_to_email(a_s_r)
    subject "Urgent: Request to Review from The Oncologist (#{corres_author.full_name})"   
    @message = content
    body :message=>@message
    values_hash.merge!(message_params(a_s_r.reviewer.id))
  end


  def reviewer_coi_notice(a_s_r,values_hash)
    set_params
    recipients user_to_email(a_s_r)
    subject "[#{a_s_r.article_submission.title}] Thank you for updating your Financial Disclosure form"
    @message = UserTemplate.get_template('reviewer_manuscript_coi_notice', a_s_r)
    body :message=>@message
    values_hash.merge!(message_params(a_s_r.reviewer.id)) 
  end


  def reviewer_accepts_or_declines(a_s_r)
    set_params
    recipients [App::Config.editorial_office_email].flatten + [App::Config.submissions_email].flatten
    subject "[#{a_s_r.user.name} #{a_s_r.article_submission.title}]"
    #@message = UserTemplate.get_template('reviewer_accepts_or_declines_notice', a_s_r)
    body :a_s_r=>a_s_r
  end

  def reviewer_comments_completed(a_s_r)
    set_params
    recipients [App::Config.editorial_office_email].flatten + [App::Config.submissions_email].flatten
    subject "[#{a_s_r.user.name}, #{a_s_r.article_submission.title}]"
    #@message = UserTemplate.get_template('reviewer_accepts_or_declines_notice', a_s_r)
    body :a_s_r=>a_s_r
  end


  def reviewer_confirm_receipt_and_thank_you(a_s_r,content,values_hash)
      subject    'Just hit reply to response from reviewer'
      set_params
      corres_author = a_s_r.article_submission.corresponding_author
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))
  end
  
  
  def reviewer_first_reminder_for_packet(a_s_r,content,values_hash)
      man_num = a_s_r.article.manuscript_num
      corres_author = a_s_r.article_submission.corresponding_author
      subject    'Requesting Update: Reviewer Packet from The Oncologist (#{man_num} #{corres_author.full_name})'
      set_params
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))
  end
   

   def reviewer_deliever_message(a_s_r,content,values_hash_subject)
      set_params
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))  
   end

   def reviewer_urgent_notification(a_s_r,content,values_hash)
      set_params
      corres_author = a_s_r.article_submission.corresponding_author
      subject   "Urgent Message For #{a_s_r.reviewer.full_name}"
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))
   end

  
  def reviewer_packet_for_the_oncologist(a_s_r,content,values_hash)
    set_params
    man_num = a_s_r.article_submission.manuscript_number
    corres_author = a_s_r.article_submission.corresponding_author
    subject    "Reviewer Packet from The Oncologist (#{man_num} #{corres_author.full_name})"
    recipients user_to_email(a_s_r)
    from       @@from_address
    @message = content
    body      :message=>@message
     values_hash.merge!(message_params(a_s_r.reviewer.id))
  end

  
   def reviewer_check_in_for_packet(a_s_r,content,values_hash)
      man_num = a_s_r.article_submission.manuscript_number
      corres_author = a_s_r.article_submission.corresponding_author
      subject    "Requesting Update: Reviewer Packet from The Oncologist (#{man_num} #{corres_author.full_name})"
      set_params
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))
  end


  def reviewer_request_response_reminder(a_s_r,content,values_hash)
       man_num = a_s_r.article_submission.manuscript_number
      corres_author = a_s_r.article_submission.corresponding_author
      subject  "Requesting Update: Reviewer Packet from The Oncologist (#{man_num} #{corres_author.full_name})"

      set_params
      corres_author = a_s_r.article_submission.corresponding_author
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))
  end

    def reviewer_first_reminder_for_packet(a_s_r,content,values_hash)
      man_num = a_s_r.article_submission.manuscript_number
      corres_author = a_s_r.article_submission.corresponding_author
      subject  "Requesting Update: Reviewer Packet from The Oncologist (#{man_num} #{corres_author.full_name})"
      set_params
      corres_author = a_s_r.article_submission.corresponding_author
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))
  end


  def reviewer_second_reminder_for_packet(a_s_r,content,values_hash)   
      man_num = a_s_r.article_submission.manuscript_number
      corres_author = a_s_r.article_submission.corresponding_author
      subject  "Requesting Update: Reviewer Packet from The Oncologist (#{man_num} #{corres_author.full_name})"
      set_params
      corres_author = a_s_r.article_submission.corresponding_author
      recipients user_to_email(a_s_r)
      from       @@from_address
      @message = content
      body      :message=>@message
      values_hash.merge!(message_params(a_s_r.reviewer.id))
  end
  
  
  def reviewer_thank_you_but_unable_with_alternate(article_submission_reviewer,values_hash)
    subject    'Thank you for your suggestion of an alternate reviewer'
    recipients user_to_email(article_submission_reviewer)
    set_params  
    @message = UserTemplate.get_template('reviewer_thank_you_but_unable_with_alternate',article_submission_reviewer.reviewer)
    body     :message => @message  
    values_hash.merge!(message_params(article_submission_reviewer.reviewer.id))
  end

  def reviewer_thank_you_but_unable(article_submission_reviewer,values_hash)
    subject    'Thank You For Your Tme.'
    recipients user_to_email(article_submission_reviewer)
    set_params
    @message = UserTemplate.get_template('reviewer_thank_you_but_unable',article_submission_reviewer.reviewer)
    body     :message => @message   
  end

 def reviewer_comment_copy(a_s_r,values_hash)
   subject "Thank You For Reviewing #{a_s_r.article_submission.title}"
   recipients user_to_email(a_s_r)
   set_params
   values_hash.merge!(message_params(a_s_r.reviewer.id))
   comments = ReviewerCommentReport.new(a_s_r.article_submission,a_s_r)
   @message = UserTemplate.get_template('reviewer_comments_email',comments)
 end
 
 
 
 def reviewer_comment_reminder(a_s_r,values_hash)
   subject "Thank You For Reviewing #{a_s_r.article_submission.title}"
   recipients user_to_email(a_s_r)
   set_params
   values_hash.merge!(message_params(a_s_r.reviewer.id))
   @message = UserTemplate.get_template('reviewer_comments_reminder_email',a_s_r)
 end
#reviewer_request_response_reminder
#reviewer_thank_you_but_unable
#reviewer_thank_you_but_unable_with_alternate
#reviewer_packet_for_the_oncologist
#reviewer_first_reminder_for_packet
#reviewer_second_reminder_for_packet
#reviewer_confirm_receipt_and_thank_you

 
  protected
  
   def user_to_email(article_submission_reviewer)
     reviewer = article_submission_reviewer.reviewer
     unless reviewer.supress_email
       user_name = reviewer.full_name ?  reviewer.full_name.strip : ""
       email_addr = reviewer.email ? reviewer.email.strip : ""
       return "#{user_name} <#{email_addr}>"
      # return RAILS_ENV == "production" ? "#{user_name} <#{email_addr}>": App::Config.test_email
     else
       return ""
    end
  end
  
  def set_params(options={})
    from          App::Config.reviewer_from_email
    headers       "Reply-to" => App::Config.reviewer_from_email
    sent_on       Time.now
    bcc           "marty3rd@alphamedpress.com"
    content_type  "text/html"
  end
  
  def message_params(reviewer_id)
    
    return {:content=>@message,:recipient=>recipients,:sender=>from,:subject=>subject,:recipient_user_id=>reviewer_id}
    
  end
  



end
