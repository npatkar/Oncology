require 'fastercsv'
class AdminController < ApplicationController
  
  before_filter :must_be_admin
  before_filter :check_filter_params, :only => [:article_submissions,:upload_updated_manuscript, :update_article_submissions_list, :search, :export_article_submissions]
  before_filter :load_article_submissions, :only => [:article_submissions,:upload_updated_manuscript, :update_article_submissions_list, :search, :export_article_submissions]
  
  
  def notify_finance_to_charge_pub_fee
    @article_submission = @article.article_submission if @article
    
    if @article_submission # This will be loaded by application_controller as they are sending article_submission_id
      logger.info("*** found article_submission: #{@article_submission.id}")
      email_hash = {:category=>EmailLog::SENT_PROCESS_PUB_CHARGE_REMINDER}
      if Notifier.deliver_process_pub_charge_reminder(@article_submission,email_hash) 
         EmailLog.create(email_hash)
        render :status => 100
        return
      end
    else
      logger.info("*** did not find an article_submission")
    end
    render :status => 403
    add_audit_trail(:details => "Notifying finance to charge pub fee") 
  end
  
  def send_to_cadmus
   as = ArticleSubmission.find(params[:id])
   start = Time.now
   if as.article
     cmd = "rake build_zip_file id=#{params[:id]} RAILS_ENV=#{Rails.env} --trace >> #{Rails.root}/log/cadmus.log &"
     system cmd
   end
   done = Time.now
   render :update do |page|
       page.replace_html "ajax_popup_content",:text=>"Manuscript Sent To Cadmus #{done-start}"
   end
 end
  
  def send_coi_reminder_to_author
    @parent = nil
    begin
      @parent = Contribution.find(params[:contribution_id])
    rescue
      logger.info("error..........")
    end
    email_hash = {:category=>EmailLog::SENT_AUTHOR_COI_REMINDER}
    if @parent && Notifier.deliver_manuscript_coi_link(@parent,email_hash)
      @parent.email_logs.create(email_hash)
      add_audit_trail(:details => "Sent manuscript COI link to user", 
                      :user_acted_on_id => @parent.user.id, 
                      :article_submission_id => @parent.article_submission.id)
      render :text => '', :status => 200, :layout => false
    else
      add_audit_trail(:details => "Tried but failed to send manuscript COI link to user", 
                      :user_acted_on_id => @parent.user.id, 
                      :article_submission_id => @parent.article_submission.id)
      render :text => '', :status => 500, :layout => false
    end
  end
  
  def send_generic_message
    @user = User.find(params[:id])  
    email_hash = {}
    if @user&& Notifier.deliver_generic_email(@user,email_hash,params[:message])
      @user.email_logs.create(email_hash)
      render :update do |page|
        page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      end
    else
      render :update do |page|
        page.replace_html "ajax_popup_content",:text=>"Email Sending Failed. Please try again"
      end
    end
  end
  
  def send_coi_reminder_to_reviewer
    @a_s_r = ArticleSubmissionReviewer.find(params[:article_submission_reviewer_id])
    email_hash = {:category=>EmailLog::SENT_REVIEWER_COI_REMINDER}
    if @a_s_r && ReviewerNotifications.deliver_manuscript_coi_link(@a_s_r,email_hash)
      @a_s_r.email_logs.create(email_hash)
      add_audit_trail(:details => "Sent manuscript COI link to user", 
                      :user_acted_on_id => @a_s_r.reviewer.id, 
                      :article_submission_id => @a_s_r.article_submission.id)
      render :text => '', :status => 200, :layout => false
    else
      add_audit_trail(:details => "Tried but failed to send manuscript COI link to user", 
                      :user_acted_on_id => @a_s_r.reviewer.id, 
                      :article_submission_id => @a_s_r.article_submission.id)
      render :text => '', :status => 500, :layout => false
    end
  end
  
  
  def update_article_submissions_list
    render :update, :type =>'text/javascript'  do |page|
      page.replace_html 'article_submissions_list', :partial => 'article_submissions_list'
    end
    add_audit_trail(:details => "Updated the article submissions page")
  end
  
  
  def article_submissions
    add_audit_trail(:details => "Viewed the article submissions page")
    #CHANGED THIS. 0 WAS CAUSING AN ERROR
    @page = params[:page]||1
  end
  
  
  def article_reviewers
    @article_submission = ArticleSubmission.find(params[:id])
    @section = @article_submission.article_section
    @sect_reviewers = @section.reviewers
    @avail_reviewers = @section.reviewers.reject{|rev| @article_submission.reviewers.include?(rev)}
    @article_section = ArticleSection.find(params[:section_id])
    respond_to do |format|
      format.html #{ render :partial=> 'article_reviewers'}
      format.xml  { render :xml => @as.reviewers}
      format.js { render :partial=> 'article_reviewers'}
    end   
  end
  
  def switch_reviewer_subjects
    @article_submission = ArticleSubmission.find(params[:id])
    @section = ArticleSection.find(params[:section_id])
    @avail_reviewers = @section.reviewers.reject{|rev| @article_submission.reviewers.include?(rev)}
  end
  
  def update_reviewers
    @article_submission = ArticleSubmission.find(params[:id])
    reviewer_ids = params[:reviewer_ids]||[]
    @article_submission.save_reviewers(reviewer_ids)
    @article_submission.article_submission_reviewers.each do|rev|
    rev.change_status("reviewer_not_yet_invited") if rev.current_status.nil?                           
  end
  
  
  respond_to do |format|
    format.html #{ render :partial=> 'article_reviewers'}
    format.xml  { render :xml => @article_submission.reviewers}
    format.js 
  end   
end


def remove_article_reviewer
  @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])            
  @article_submission = @article_submission_reviewer.article_submission
  @article_submission_reviewer.destroy
  @no_popup = true
  respond_to do |format|
    format.html 
    format.js {render :update_reviewers}
  end   
  
end

def give_up_on_reviewer
  #TODO put in failed message if exception occurs
  @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id]) 
  @article_submission_reviewer.change_status("reviewer_given_up")
  render :js => "alert('Reviewer has been given up on')"
  
end

def export_article_submissions
  load_article_submissions
  
  labels = ['Started', 'Title', 'Name', 'Email', 'Submitted', 'Credit Card Last Four', 'Imported to PF?', 'Initial Fee', 'Pub Fee']
  rows = []
  @article_submissions.each do |as|
    rows << [as.create_date.strftime("%x"), 
    as.title,
     (as.corresponding_author && as.corresponding_author.rev_name),
     (as.corresponding_author && as.corresponding_author.email),
     (as.committed ? as.committed.strftime("%x") : 'Not Submitted'),
     (as.corresponding_author && as.corresponding_author.credit_card ? as.corresponding_author.credit_card.num_last_four : 'No Credit Card'),
     (as.imported_to_pf ? as.imported_to_pf.strftime("%x") : 'Not Imported'),
     (as.initial_charge_processed ? as.initial_charge_processed.strftime("%x") : 'Not Processed')]
  end
  send_csv(:labels => labels, :rows => rows)
  add_audit_trail(:details => 'Exported article submissions') 
end


def process_initial_charge
  @article_submission = ArticleSubmission.find(params[:id])
  if @article_submission.do_initial_charge
    add_audit_trail(:details => 'Processing initial publication fee - processed successfully')
    render :update do |page|
      page.replace_html("initial_charge_processed_#{@article_submission.id}", @article_submission.initial_charge_processed.strftime("%x"))
    end
  else
    add_audit_trail(:details => 'Processing initial publication fee - failure to process')
    render :update do |page|
      page.replace_html("initial_charge_processed_#{@article_submission.id}", @article_submission.initial_charge.last_cc_transaction.message)
    end
  end
end  


def process_pub_charge
  @article_submission = ArticleSubmission.find(params[:id])
  if @article_submission.do_pub_charge
    add_audit_trail(:details => 'Processed publication charge - processed successfully')
    render :update do |page|
      page.replace_html("pub_charge_processed_#{@article_submission.id}", @article_submission.pub_charge_processed.strftime("%x"))
    end
  else
    add_audit_trail(:details => 'Processed publication charge - failed to process')
    render :update do |page|
      page.replace_html("pub_charge_processed_#{@article_submission.id}", @article_submission.pub_charge.last_cc_transaction.message)
    end
  end
end  


def destroy_article_submissions
  process_article_submission_ids do |as_id, page| 
    @article_submission = ArticleSubmission.find(as_id)
    if @article_submission.destroy
      add_audit_trail(:details => "Deleted an article submission")
      page.select("#article_submission_#{as_id} input").first.disabled = true
      page.hide("article_submission_#{as_id}")
    end
  end
end


def import_to_pf
  @article_submission = ArticleSubmission.find(params[:id])
  #if advance_sequence && @article_submission.import_to_pf
  if @article_submission.import_to_pf
    add_audit_trail(:details => 'Imported submission to pubforecaster - successful import')   
    render :update do |page|
      page.replace_html("imported_to_pf_#{@article_submission.id}", @article_submission.imported_to_pf.strftime("%x"))
      page.replace_html("article_submission_#{@article_submission.id}_man_num",@article_submission.manuscript_number())
    end
  else
    add_audit_trail(:details => 'Imported submission to pubforecaster - failed to import')
    render :update do |page|
      page.replace_html("imported_to_pf_#{@article_submission.id}", "problem importing to PF")
    end
  end
end

def change_publish_date
  article_submission = ArticleSubmission.find(params[:id])
  date = params["date_#{article_submission.id}"]
  article_submission.article.publish_date = date
  msg = ""
  if(article_submission.article.save)
    msg = "Publish Date Changed to #{date}"
  else
    msg = "Publish Date Not Changed. Please Try Again"
  end
  render :js =>"AjaxPopup.OpenBoxWithText($('submission_publish_date_form_#{article_submission.id}'),true,\"#{msg}\",null)"
end

def upload_updated_manuscript  
  UpdatedManuscript.destroy_all(:manuscript_id=>params[:manuscript_id],:article_submission_id=>params[:id])     
  @updated_manuscript = UpdatedManuscript.new(params[:updated_manuscript])
  @updated_manuscript.article_submission = ArticleSubmission.find(params[:id])
  @updated_manuscript.manuscript = Manuscript.find(params[:manuscript_id])   
  if @updated_manuscript.save
    flash[:notice] = "The updated manuscript was added successfully"
  else
    flash[:notice] = "There was a problem adding the updated manuscript"
  end
  redirect_to :action=>:article_submissions,:page=>params[:page]
end


def advance_manuscript_sequence   
  if advance_sequence
    render :text=> @configuration.value,:status=>200
  else
    render :text=>"Process Failed",:status=>500
  end
end


def invite_to_review
  @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
  @reviewer = @article_submission_reviewer.user
  @article_submission = @article_submission_reviewer.article_submission 
  respond_to do |format|
    format.html # index.html.erb
    format.js 
  end 
end


def send_reviewer_invite
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  article_submission = @a_s_r.article_submission
  reviewer =  @a_s_r.user
  @message = params[:message]
  email_hash = {:category=>EmailLog::SENT_REVIEWER_INVITE}
  
  if reviewer && ReviewerNotifications.deliver_reviewer_invite_link(@a_s_r,@message,email_hash)
    add_audit_trail(:details => "Sent reviewer _invite_link to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    @a_s_r.change_status("reviewer_invited_awaiting_response")    
    email_log = EmailLog.create(email_hash)
    @a_s_r.email_logs << email_log    
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      page.replace_html "emails_box_#{@a_s_r.id}",:partial=>"reviewer_emails"
    end    
  else
    add_audit_trail(:details => "Tried but failed to send reviewer invite link to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Sending Failed"
    end     
  end
end


def request_response_reminder
  @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
  @reviewer = @article_submission_reviewer.user
  @article_submission = @article_submission_reviewer.article_submission 
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"request_response_reminder"
  end   
end


def send_request_response_reminder
  @a_s_r= ArticleSubmissionReviewer.find(params[:id])
  article_submission = @a_s_r.article_submission
  reviewer = @a_s_r.user
  @message = params[:message]
  email_hash = {:category=>EmailLog::SENT_REVIEWER_INVITE}
  if reviewer && ReviewerNotifications.deliver_reviewer_invite_link(@a_s_r,@message,email_hash)
    add_audit_trail(:details => "Sent reviewer _invite_link to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    @a_s_r.change_status("reviewer_invited_awaiting_response")    
    email_log = EmailLog.create(email_hash)
    @a_s_r.email_logs << email_log    
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      page.replace_html "emails_box_#{@a_s_r.id}",:partial=>"reviewer_emails"
    end    
  else
    add_audit_trail(:details => "Tried but failed to send reviewer invite link to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Sending Failed"
    end     
  end
end

def reviewer_packet 
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"reviewer_packet"
  end  
end

def send_reviewer_packet
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  article_submission = @a_s_r.article_submission_id
  reviewer =  @a_s_r.reviewer
  message = params[:message] 
  email_hash = {:category=>EmailLog::SENT_REVIEWER_PACKET}
  if reviewer && ReviewerNotifications.deliver_reviewer_packet_for_the_oncologist(@a_s_r,message,email_hash)
    add_audit_trail(:details => "Sent reviewer packet _link to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    email_log = EmailLog.create(email_hash)
    @a_s_r.email_logs << email_log
    @a_s_r.change_status("reviewer_need_comments")   
    deadline = (@a_s_r.days_to_comment||10).days.from_now
    @a_s_r.update_attributes(:comments_deadline=>deadline) 
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      page.replace_html "emails_box_#{@a_s_r.id}",:partial=>"reviewer_emails"
    end     
  else
    add_audit_trail(:details => "Tried but failed to send reviewer packet  to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Sending Failed"
    end     
  end
end

def check_in_for_packet
  
  @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
  @reviewer = @article_submission_reviewer.user
  @article_submission = @article_submission_reviewer.article_submission 
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"check_in_for_packet"
  end   
  
  
end

def send_check_in_for_packet
  
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  article_submission = @a_s_r.article_submission_id
  reviewer =  @a_s_r.reviewer
  message = params[:message]    
  email_hash = {:category=>EmailLog::SENT_REVIEWER_CHECK_IN}
  if reviewer && ReviewerNotifications.deliver_reviewer_check_in_for_packet(@a_s_r,message,email_hash)
    add_audit_trail(:details => "Sent reviewer check_in to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    email_log = EmailLog.create(email_hash)
    @a_s_r.email_logs << email_log
    
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      page.replace_html "emails_box_#{@a_s_r.id}",:partial=>"reviewer_emails"
    end     
  else
    add_audit_trail(:details => "Tried but failed to send reviewer packet  to user", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Sending Failed"
    end     
  end
  
  
  
  
end


def first_reminder_for_packet
  @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
  @reviewer = @article_submission_reviewer.user
  @article_submission = @article_submission_reviewer.article_submission 
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"first_reminder_for_packet"
  end   
  
  
end

def send_first_reminder_for_packet  
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  article_submission = @a_s_r.article_submission_id
  reviewer =  @a_s_r.reviewer
  message = params[:message] 
  email_hash = {:category=> EmailLog::SENT_REVIEWER_FIRST_REMINDER}
  if reviewer && ReviewerNotifications.deliver_reviewer_request_response_reminder(@a_s_r,message,email_hash)
    add_audit_trail(:details => "Sent first reminder to reviewer", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    email_log = EmailLog.create(email_hash)
    @a_s_r.email_logs << email_log
    
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      page.replace_html "emails_box_#{@a_s_r.id}",:partial=>"reviewer_emails"
    end     
  else
    add_audit_trail(:details => "Tried but failed to sending first reminder to reviewer", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Sending Failed"
    end     
  end
end

def second_reminder_for_packet
  @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
  @reviewer = @article_submission_reviewer.user
  @article_submission = @article_submission_reviewer.article_submission 
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"second_reminder_for_packet"
  end       
end

def send_second_reminder_for_packet  
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  article_submission = @a_s_r.article_submission_id
  reviewer =  @a_s_r.reviewer
  message = params[:message] 
  email_hash = {:category=> EmailLog::SENT_REVIEWER_SECOND_REMINDER}
  if reviewer && ReviewerNotifications.deliver_reviewer_second_reminder_for_packet(@a_s_r,message,email_hash)
    add_audit_trail(:details => "Sent second reminder to reviewer", :user_acted_on_id => reviewer.id, :article_submission_id => article_submission.id)
    email_log = EmailLog.create(email_hash)
    @a_s_r.email_logs << email_log
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      page.replace_html "emails_box_#{@a_s_r.id}",:partial=>"reviewer_emails"
    end      
  else
    add_audit_trail(:details => "Tried but failed to sending sescond reminder to reviewer", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Sending Failed"
    end     
  end
end

def coauthor_coi_message
  @contr = Contribution.find(params[:id])
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"admin/coi_messages/coauthor_coi_message"
  end   
end
def generic_message
  @user = User.find(params[:id])
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"admin/generic_email"
  end   
end

def reviewer_coi_message
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"admin/coi_messages/reviewer_coi_message"
  end   
end


def send_custom_coi_reminder_to_author
  @parent = Contribution.find(params[:id])
  email_hash = {:type=>EmailLog::SENT_AUTHOR_COI_REMINDER,:content=>@message}
  if @parent && Notifier.deliver_custom_manuscript_coi_link(@parent,email_hash,params[:message])
    @parent.email_logs.create(email_hash)
    add_audit_trail(:details => "Sent manuscript COI link to user", 
                      :user_acted_on_id => @parent.user.id, 
                      :article_submission_id => @parent.article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content","Message Succesfully Sent"
    end   
  else
    add_audit_trail(:details => "Tried but failed to send manuscript COI link to user", 
                      :user_acted_on_id => @parent.user.id, 
                      :article_submission_id => @parent.article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content","Message Failed. Please try again."
    end   
  end
end

def send_custom_coi_reminder_to_reviewer
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  email_hash = {:category=>EmailLog::SENT_REVIEWER_COI_REMINDER}
  if @a_s_r && ReviewerNotifications.deliver_custom_manuscript_coi_link(@a_s_r,email_hash,params[:message])
    @a_s_r.email_logs.create(email_hash)
    add_audit_trail(:details => "Sent manuscript COI link to user", 
                      :user_acted_on_id => @a_s_r.reviewer.id, 
                      :article_submission_id => @a_s_r.article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content","Message Succesfully Sent"
    end   
  else
    add_audit_trail(:details => "Tried but failed to send manuscript COI link to user", 
                      :user_acted_on_id => @a_s_r.reviewer.id, 
                      :article_submission_id => @a_s_r.article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content","Message Sending Failed. Please Try Again"
    end   
  end
end



def urgent_message
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"urgent_message"
  end   
end

def send_urgent_message
  @a_s_r = ArticleSubmissionReviewer.find(params[:id])
  article_submission = @a_s_r.article_submission_id
  reviewer =  @a_s_r.reviewer
  message = params[:message] 
  email_hash = {:category=> EmailLog::SENT_REVIEWER_URGENT_NOTIFICATION }
  if reviewer && ReviewerNotifications.deliver_reviewer_urgent_notification(@a_s_r,message,email_hash)
    add_audit_trail(:details => "Sent Urgent Notfication To Reviewer", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    email_log = EmailLog.create(email_hash)
    @a_s_r.email_logs << email_log  
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Succesfully Sent"
      page.replace_html "emails_box_#{@a_s_r.id}",:partial=>"reviewer_emails"
    end      
  else
    add_audit_trail(:details => "Tried but failed to send urent message to reviewer", 
                        :user_acted_on_id => reviewer.id, 
                        :article_submission_id => article_submission.id)
    render :update do |page|
      page.replace_html "ajax_popup_content",:text=>"Email Sending Failed"
    end     
  end  
end


def accepted_reviewer_list
  @rev_list = ArticleSubmissionReviewer.get_reviewer_list_with_status("reviewer_accepted")  
end


def alternate_reviewer_list
  @rev_list = ArticleSubmissionReviwer.get_reviewer_list_with_status("reviewer_declined_with_alternate") 
end

def manage_manuscript_review
  @article_submission = ArticleSubmission.find(params[:id])
  @manuscript = @article_submission.manuscript
  @article = @article_submission.article
  
end


def edit_article_submission_field
  @article_submission = ArticleSubmission.find(params[:id])
  @field = params[:field]
  render :update do |page|
    page.replace_html "ajax_popup_content",:partial=>"edit_article_submission_field"
  end    
  
end

def save_notes_for_submission
  @as= ArticleSubmission.find(params[:id])
  if @as.update_attributes!(params[:article_submission])
    render :update do |page|
      page.replace_html "ajax_popup_content","Information Saved"
    end    
  else
    render :update do |page|
      page.replace_html "ajax_popup_content","Something went wrong. Please try again."
    end
  end
  
end

def get_reviewer_author_comments
  @asr = ArticleSubmissionReviewer.find(params[:id])
  remarks = @asr.reviewer_comment ? @asr.reviewer_comment.comment_to_author : "No Comments Yet"
  
  render :update do |page|
    page.replace_html "ajax_popup_content",remarks
  end    
  
end

def get_reviewer_comments
  @asr = ArticleSubmissionReviewer.find(params[:id])
  @type = params[:remark_type]
  remarks = ""
  if @asr.reviewer_comment &&
    remarks = @asr.reviewer_comment.latest_revision(@type)
    remarks = "Comments have not been sanitized. Go to the Manage Review Page to edit." if remarks.blank?
  end
  
  render :update do |page|
    page.replace_html "ajax_popup_content",remarks
  end    
  
end

def create_revision
  @original = ReviewerComment.find(params[:id])
  @revision =  ReviewerCommentRevision.create(params[:reviewer_comment_revisions])
  render :update do |page|
    if @original.reviewer_comment_revisions << @revision
      page.replace_html "ajax_popup_content","Revisions Saved"
    else
      page.replace_html "ajax_popup_content","Revision Submission Failed. Please Try Again"
    end
  end
end

def revision_box
  @type = params[:remark_type]
  @reviewer_comments = ReviewerComment.find(params[:id])
  @last = ReviewerCommentRevision.find(:last,:conditions=>[ "reviewer_comment_id= ? and #{@type} is not null", @reviewer_comments.id])
  @obj = @last || @reviewer_comments
  @value = @obj.send(@type)
  @value = @value.blank? ? "Not Yet Entered" : @value
  render :update do |page|
    if @reviewer_comments
      page.replace_html "ajax_popup_content",:partial=>"revision_box"
    else
      page.replace_html "ajax_popup_content","No Comments Have Been Entered"
    end
  end    
end


def change_reviewer_deadline 
  @asr = ArticleSubmissionReviewer.find(params[:id])
  deadline = params[:comments_deadline]
  if @asr.update_attributes(:comments_deadline=>deadline)
    render :js=>"alert('Deadline Set To #{deadline}')"
  else   
    render :js=>"alert('Process Failed. Please try again')"
  end  
end


def remove_article_submission  
  @as = ArticleSubmission.find(params[:id])
  @as.faux_delete(true)  
  render :js=>"$('article_submission_#{@as.id}').textDecoration='line-through';$('article_submission_#{@as.id}').onclick='null')"
end

def add_publisher_comments
  @as = ArticleSubmission.find(params[:id])
  respond_to do|format|
  format.html
  format.js {render :partial=>"add_publisher_comments"}   
end
end

def add_admin_notes
@as = ArticleSubmission.find(params[:id])
respond_to do|format|
format.html
format.js {render :partial=>"add_admin_notes"}   
end
end

def save_admin_notes
  notes= params[:notes]
  @as = ArticleSubmission.find(params[:id])
  if @as.update_attribute(:admin_notes,notes)
    render :update do |page|
      page.replace_html "ajax_popup_content","Notes Ssaved"
    end    
  else
    render :update do |page|
      page.replace_html "ajax_popup_content","Something went wrong. Please try again."
    end
  end  
end 



def mark_submission_urgent
  as = ArticleSubmission.find(params[:id])
  as.admin_urgent = true
  as.save(false)
  render :update do |page|
    page << "$(\"article_submission_#{as.id}\").addClassName('urgent')"
    page.replace_html "urgent_links_#{as.id}", link_to_remote("Mark Normal", :url=>{:controller => 'admin',:action => 'mark_submission_normal',:id => as.id}) 
  end
end

def save_publisher_comments
  comments = params[:comments]
  @as = ArticleSubmission.find(params[:id])
  if @as.update_attribute(:publisher_comments,comments)
    render :update do |page|
      page.replace_html "publisher_comments_#{@as.id}",comments
      page << "AjaxPopup.CloseWindow()"
    end    
  else
    render :update do |page|
      page.replace_html "ajax_popup_content","Something went wrong. Please try again."
    end
  end  
end 


def mark_submission_normal
  as = ArticleSubmission.find(params[:id])
  as.admin_urgent = false
  as.save(false)
  render :update do |page|
    page << "$(\"article_submission_#{as.id}\").removeClassName('urgent')"
    page.replace_html "urgent_links_#{as.id}", link_to_remote("Mark Urgent", :url=>{:controller => 'admin',:action => 'mark_submission_urgent',:id => as.id}) 
  end
  
end



def provisionally_accept
  @article_submission = ArticleSubmission.find(params[:id])
  @article_submission.change_status(ArticleSubmission::PROVISIONALLY_ACCEPTED)
  @article_submission.update_attribute(:resubmitted,true)
  rev = @article_submission.create_revision!
  msg = "Submission Provisionally Accepted. Revision #{rev.version} has been created"
  logger.info(msg)
  render :js =>"AjaxPopup.OpenBoxWithText($('provisional_link_#{@article_submission.id}'),true,\"#{msg}\",null)"
end

  def reconcile_mismatched_statuses
    @article_submissions = ArticleSubmission.find(:all)
    @article_submissions.delete_if do |as|
      if !as.article
        true # Remove all submissions without an associated article
      elsif !as.article.article_status
        true # Remove all submissions with articles that don't have valid statuses
      elsif as.current_status.name == as.article.article_status.status
        true # Remove all submissions whose statuses match their article's status
      else
        false # Don't remove the rest 
      end
    end
    if @article_submissions.length > 0
      @msg = "<ul>"
      @article_submissions.each do |as|
        old_status_name = as.current_status_name
        as.set_current_status_from_pf_status
        logger.info("**** Changing the status of article_submission (#{as.id}) from: '#{old_status_name}' to: '#{as.current_status.name}'****")
        @msg = @msg + ("<li>Changing the status of article_submission (#{as.id}) from: '#{old_status_name}' to: '#{as.current_status.name}'</li>")
      end
      @msg = @msg + "</ul>"
    else
      @msg = "No mismatched statuses were found. (with valid article statuses)"
    end
    flash[:notice] = @msg
  end


 


private  
def advance_sequence
  @configuration = Configuration.find_by_name("manuscript_sequence")
  if(@configuration.nil?)
    @configuration = Configuration.new({:name=>"manuscript_sequence"}) 
  end
  val = @configuration.value
  
  #T10-123 put in article table under manuscript_num
  curr_year= Time.now.strftime("%y")
  if(val!=0 && val && val.match(/T\d{2}-\d+/))
    toks = val.split("-")
    tok_1 = toks[0]
    tok_2 = toks[1]
    seq =  "T#{curr_year}" == tok_1 ?  tok_2.to_i + 1 : 0  
    new_seq = "T#{curr_year}-#{seq}"
  else
    new_seq = "T#{curr_year}-1"
  end
  
  @configuration.value = new_seq
  
  return @configuration.save
end





# Filter on: manuscript title, creation date, submission date, email, author
def load_article_submissions
  joins = [:contributions => [:user]]
  includes = []
  conditions = ['1']
  if @show_urgent
    add_conditions(conditions, 'article_submissions.admin_urgent = 1')
  end
  case @committed
    when 'no'
    add_conditions(conditions, 'article_submissions.committed IS NULL')
    when 'yes'
    add_conditions(conditions, 'article_submissions.committed IS NOT NULL')
  end
  
  if @date_range.to_i > 0
    add_conditions(conditions, 'article_submissions.committed > (DATE_SUB(NOW(), INTERVAL "?" DAY))', @date_range)
  end
  
  if @search
    unless @search_by == "num"
      add_conditions(conditions, '(article_submissions.title LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ? OR users.email LIKE ?)', ["%#{@search}%", "%#{@search}%", "%#{@search}%", "%#{@search}%"])
    else
      
      @article_submissions = ArticleSubmission.find_by_manuscript_number(@search)
      @article_submissions = @article_submissions.select{|as|as.last_revision==true && (!as.committed.blank?|| !as.version.blank?)}
      list = @article_submissions.collect{|a|a.id}
      @article_submissions = (ArticleSubmission.paginate :page => params[:page], :per_page => @per_page, :conditions => {"id"=>list},:group=>"id", :order => "#{@sort_by} #{@direction}").uniq

      return @article_submissions
    end
  end
  
    #add_conditions(conditions,'article_submissions.version is NULL or article_submissions.version = 1')
  if @search_by_status
    @article_submissions = ArticleSubmission.paginate_by_sql([ArticleSubmission::STATUS_SQL,@search_by_status], :page => params[:page], :per_page => @per_page)
    return  @article_submissions 
  end
  @article_submissions = (ArticleSubmission.paginate :page => params[:page], :per_page => @per_page, :joins=>joins, :conditions=>conditions, :order => "article_submissions.#{@sort_by} #{@direction}").uniq
end

def check_filter_params
 
  @search = nil
  if params.has_key?(:search)
    @search = params[:search]
    @search_by = @search=~/T\d{2}-\d+(\.R\d+)?/ ? "num" : "text"

  end
  @search_by_status = params[:status] ? params[:status][:key] : nil
  @show_urgent = params[:show_urgent]
  @sort_by = 'committed'    # default
  if  ArticleSubmission.columns.collect {|c| c.name}.include?(params[:sort_by])
    @sort_by = params[:sort_by]
  end
  
  @direction = 'DESC'   # default
  if params.has_key?('direction') && params['direction'] == 'ASC'
    @direction = 'ASC'
  end
  
  @per_page = 100    # default
  if params.has_key?('per_page') && params[:per_page].to_i > 0
    @per_page = params[:per_page].to_i
  end
  
  @date_range = 0   # default
  if params.has_key?('date_range') && params[:date_range].to_i >= 0
    @date_range = params[:date_range].to_i
  end
  
  @committed = 'all'  # default
  if params.has_key?('committed')
    if params[:committed] == 'yes'
      @committed = 'yes'
    elsif params[:committed] == 'no'
      @committed = 'no'
    else
      # Doesn't make sense to specify a date range while not filtering on 'committed'
      @date_range = 0
    end
  end
  #logger.info("********committed=#{@committed}")
  
  @update_url_wo_action  =
  { :sort_by                 => @sort_by, 
                     :direction               => @direction,
                     :committed               => @committed, 
                     :date_range              => @date_range,
                     :per_page                => @per_page }
  
  @update_url  = { :action                  =>'update_article_submissions_list', 
                     :sort_by                 => @sort_by, 
                     :direction               => @direction,
                     :committed               => @committed, 
                     :date_range              => @date_range,
                     :per_page                => @per_page }
end




def process_article_submission_ids
  render :update do |page|
    params[:article_submission_ids].each do |as_id|
      page.replace_html("article_submission_#{as_id}_status", :partial=>'/layouts/processing')
      begin 
        if yield(as_id, page)
          page.replace_html("article_submission_#{as_id}_status", :partial=>'/layouts/check_small')
          #            unless page["article_submission_#{as_id}"].nil?
          #              page.replace_html("article_submission_#{as_id}_status", '')
          page.select("#article_submission_#{as_id}").first.visual_effect(:highlight)
          #            end
        else
          page.replace_html("article_submission_#{as_id}_status", :partial=>'/layouts/x_small')
        end
      rescue
        page.replace_html("article_submission_#{as_id}_status", :partial=>'/layouts/x_small')
      end
      page.select("#article_submission_#{as_id} input").first.checked = false
    end
  end
end

def send_csv(result_set)
  csv_string = FasterCSV.generate do |csv|
    csv << result_set[:labels]
    result_set[:rows].each {|r| csv << r}
  end
  send_data(csv_string, :type => 'text/csv; charset=utf-8, header=present', :filename => 'report.csv')
end




end
