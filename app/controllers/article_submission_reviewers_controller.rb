class ArticleSubmissionReviewersController < ApplicationController
  # GET /article_submission_reviewers
  # GET /article_submission_reviewers.xml
  
  before_filter :login_required
  #before_filter :must_be_admin,:except=>[:accept_invite,:process_invite,:manuscript,:reviewer_comments,:save_comments]
  before_filter :load_article_submission_and_reviewer, :except=>[:index,:list]
  before_filter :must_be_reviewer, :only=>[:reviewer_comments,:save_comments]
  before_filter :must_be_admin,:only=>[:admin_reviewer_comments,:admin_save_comments]
  
  def index
    @article_submission_reviewers = ArticleSubmissionReviewer.all   
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @article_submission_reviewers }
    end
  end
  
  def manuscript  

    @manuscript = @article_submission.updated_manuscript || @article_submission.manuscript
      
  end
  
  def list  
    @as = ArticleSubmission.find(params[:id])
    @reviewers = as.reviewers
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @article_submission_reviewers }
      format.js
    end   
  end
  
  # GET /article_submission_reviewers/1
  # GET /article_submission_reviewers/1.xml

  
  # GET /article_submission_reviewers/1/edit
  def edit
    @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
  end
  
  
  def accept_invite 
    @alternate_reviewer = User.new
    respond_to do |format|
      format.html
      format.js
    end  
  end
  
  
  def process_invite
    @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
    added_reviewer = !params[:reviewer].blank? && !params[:reviewer][:email].blank?  && !params[:reviewer][:first_name].blank? && !params[:reviewer][:last_name].blank? 
    current_entity_status = @article_submission_reviewer.current_entity_status
    current_entity_status.destroy if current_entity_status
    if added_reviewer
      alt_reviewer = @article_submission_reviewer.alternate_reviewer
      alt_reviewer.destroy if alt_reviewer
      @status_key = "reviewer_declined_with_alternate"
      @alternate_reviewer = User.find_or_initialize_by_email(params[:reviewer][:email])
      @alternate_reviewer.set_defaults
      @alternate_reviewer.create_by_ip = request.remote_ip
      @alternate_reviewer.set_temp_password
      @alternate_reviewer.attributes = params[:reviewer]
      @alternate_reviewer.save(false)
      @alternate_reviewer.roles << Role.find_by_key("reviewer")
      @article_submission_reviewer.alternate_reviewer = @alternate_reviewer      
      @article_submission_reviewer.save
    else
      @status_key = params[:accept_invite] == 'yes' ? "reviewer_accepted" : "reviewer_declined"
    end
    
    @article_submission_reviewer.change_status(@status_key)        
    email_hash = Hash.new
    if @status_key == "reviewer_declined"
         if  ReviewerNotifications.deliver_reviewer_thank_you_but_unable(@article_submission_reviewer,email_hash)
                email_log = EmailLog.create(email_hash)
              @article_submission_reviewer.email_logs << email_log     
         end
    elsif @status_key == "reviewer_declined_with_alternate"
           if ReviewerNotifications.deliver_reviewer_thank_you_but_unable_with_alternate(@article_submission_reviewer,email_hash)
               email_log = EmailLog.create(email_hash)
              @article_submission_reviewer.email_logs << email_log     
           end        
    end
    ReviewerNotifications.deliver_reviewer_accepts_or_declines(@article_submission_reviewer)
  end
  
  
  # POST /article_submission_reviewers
  # POST /article_submission_reviewers.xml
  def create
    @article_submission_reviewer = ArticleSubmissionReviewer.new(params[:article_submission_reviewer])
    
    respond_to do |format|
      if @article_submission_reviewer.save
        flash[:notice] = 'ArticleSubmissionReviewer was successfully created.'
        format.html { redirect_to(@article_submission_reviewer) }
        format.xml  { render :xml => @article_submission_reviewer, :status => :created, :location => @article_submission_reviewer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article_submission_reviewer.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  
  
  def reviewer_comments    
    if @article_submission_reviewer.reviewer_comment
       @comments = @article_submission_reviewer.reviewer_comment      
    else
       @comments = ReviewerComment.new
       @article_submission_reviewer.reviewer_comment = @comments
    end       
  end
  
  
  
  def admin_reviewer_comments
   if @article_submission_reviewer.reviewer_comment
       @comments = @article_submission_reviewer.reviewer_comment      
    else
       @comments = ReviewerComment.new
       @article_submission_reviewer.reviewer_comment = @comments
    end       
  end
  
  def admin_save_comments  
      @comments = @article_submission_reviewer.reviewer_comment
      if @comments.update_attributes(params[:comments])
           form_submitted = params[:submit_comments] == 'true'
           status = form_submitted ? "reviewer_comments_submitted" : "reviewer_comments_saved"
           @comments.change_status(status)          
           flash[:notice] = form_submitted ?  "Comments for this reviewer have been submitted" : "Comments for this user have been saved"
           if form_submitted
              @article_submission_reviewer.change_status("reviewer_received_comments")
              curr_stat = @article_submission_reviewer.current_entity_status
              if params[:date_received]
                 curr_stat.update_attribute(:created_at,params[:date_received])
              end
           end
      else
          flash[:notice] = "Comments Did Not Save. Please Try Again"
      end
         render :action=>"admin_reviewer_comments",:id=>@article_submission_reviewer.id     
  end 
  
  
  
  
  
  def save_comments  
      @comments = @article_submission_reviewer.reviewer_comment
      if @comments.update_attributes(params[:comments])  
           if params[:submit_comments] == 'true'
              @comments.submit!
              @article_submission_reviewer.change_status(ArticleSubmissionReviewer::SUBMITTED_COMMENTS)
              ReviewerNotifications.deliver_reviewer_comments_completed(@article_submission_reviewer)
              email_hash = Hash.new
              if ReviewerNotifications.deliver_reviewer_comment_copy(@article_submission_reviewer,email_hash)
                email_log = EmailLog.create(email_hash)
                @article_submission_reviewer.email_logs << email_log     
              end   
              flash[:notice] = "Thank You!. Your comments have been submitted"
              redirect_to :action=>"manuscript",:id=>@article_submission_reviewer.id           
           else
             
              @comments.mark_saved!
               email_hash = Hash.new
               if ReviewerNotifications.deliver_reviewer_comment_reminder(@article_submission_reviewer,email_hash)
                email_log = EmailLog.create(email_hash)
                @article_submission_reviewer.email_logs << email_log     
               end   
               
              flash[:notice] = "Thank You!. Your comments have been saved."
              render :controller => 'manuscripts', :action => 'edit', :id => @article_submission.id
           end
      else
          flash[:notice] = "Comments Did Not Save. Please Try Again"
          redirect_to :action=>"reviewer_comments",:id=>@article_submission_reviewer.id
      end
  end
  
  
  private
  
  def load_article_submission_and_reviewer   
    @article_submission_reviewer = ArticleSubmissionReviewer.find(params[:id])
    @article_submission = @article_submission_reviewer.article_submission
    @reviewer = @article_submission_reviewer.reviewer   
  end
  
  def must_be_reviewer
      unless((current_user==@reviewer) ||  current_user.has_admin?)
      flash[:notice] = "You cannot alter another users comments. "
      logger.info("Security Alert!! Unsuccessful attempt to access another reviewers comments. IP: #{request.remote_ip}, User ID: #{current_user.id}")
      redirect_to :controller => :users, :action => :login
      end   
  end
 
end
