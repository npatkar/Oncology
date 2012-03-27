class ManuscriptsController < ApplicationController
  
  before_filter :login_required
  before_filter :load_article_submission, :only=>[:review, :submit, :finished, :edit,
                :credit_card, :submit_credit_card, :remove_article_submission, :add_coauthor,
                :update_coauthor, :remove_coauthor, :edit_coauthor, :remove_all_coauthors, :send_disclosure_reminder]
  before_filter :load_contribution, :only=>[:review, :submit]

  def index
    @active_submissions = Array.new
    @committed_submissions = Array.new
    @submissions = Array.new
    #@submissions.concat(@user.article_submissions.select{|as|as.version.nil? || as.version==1})
    @submissions.concat(@user.article_submissions.select{|as|as.last_revision==true})

    #TODO clean this code up
    @review_instances = @user.article_submission_reviewers.select{|r|r.has_had_status?("reviewer_accepted")}
    @reviewed_submissions = @review_instances.collect{|r|r.article_submission}
    @submissions.each do |as| 
      if !as.article_submissions.empty?
        last = as.article_submissions.last
        if(last.display_as_complete?(@user))
          @committed_submissions << last
        else        
          @active_submissions << last unless last.isRemoved?
        end
      elsif as.display_as_complete?(@user)  
        @committed_submissions << as
      else
        @active_submissions << as unless as.isRemoved?
      end
    end
    
    @active_submissions.sort!{|x,y| (y.updated_at||y.create_date) <=> (x.updated_at||x.create_date) }
  end

  def edit
  end
  def create
  	@manuscript = Manuscript.create(params[:manuscript])
  end
  def review
    if problems_exist
      redirect_to(:action=>:index) and return
    end
  end
  
  def submit
    if problems_exist
      redirect_to(:action=>:index) and return
    end
    @article_submission.update_attributes(params[:article_submission])
    if @article_submission.payment_type == 'credit' && !@article_submission.initial_charge_processed
      render :action => 'credit_card', :id => @article_submission.id
    else
      commit_manuscript
      render :action=>'finished', :id => @article_submission.id  
    end
  end 
  
  def credit_card
  end 
  
  
  def submit_credit_card
    no_problems = !params[:sig_assent].blank?
    unless no_problems
      flash[:notice] = "You Must Agree To the Terms In Order To Proceed"
    end
    
    logger.info('**** payment_type: ' + @article_submission.payment_type)
    logger.info('**** credit_card: ' + @article_submission.corresponding_author.credit_card.inspect)
    logger.info('**** update_credit_card_info flag: ' + params[:update_credit_card_info]) if params.has_key?(:update_credit_card_info)
    
    
    if no_problems and @article_submission.initial_charge and @article_submission.initial_charge.processed
      
      msg = "There is a problem, this charge has already been processed on #{@article_submission.initial_charge.processed}. Please contact <strong><em>The Oncologist</em></strong> staff and report this error. Thank you."
      flash[:notice] = msg << '<br/><br/><p>Pamela Walker Dees, MA<br />Manuscript and CME Coordinator<br />The Oncologist<br />318 Blackwell Street, Suite 260<br />Durham, NC 27701<br />Phone: 919-680-0011 ext. 221<br />Fax: 919-680-4411<br /><a class="email" href="mailto:pamela.walkerdees@theoncologist.com">pamela.walkerdees@theoncologist.com</a></p><p></p>'
      no_problems = false 
    end
    
    # Save credit card info if no other credit card or we're updating their present card
    if no_problems and (!@article_submission.corresponding_author.credit_card or params[:update_credit_card].to_i == 1)
      logger.info("\n\n*** Trying to update or add new card *** \n\n")
      @credit_card = @article_submission.corresponding_author.credit_card || CreditCard.new
      logger.info("**** CreditCard: new_record?: #{@credit_card.new_record?}")
      @credit_card.user_id = @article_submission.corresponding_author.id
      @credit_card.update_attributes(params[:credit_card]) or no_problems = false
      logger.info("**** updated attributes on updated or new CreditCard: no_problems: #{no_problems}, credit_card.errors: #{@credit_card.errors}")
      if no_problems
        @credit_card.save or no_problems = false
      end
      logger.info("**** Created or updated a CreditCard: no_problems: #{no_problems}, credit_card.errors: #{@credit_card.errors}")
    end
    
    render :action => 'credit_card' and return   unless no_problems
    
    success = @article_submission.do_initial_charge 
    @article_submission.reload
    if success   
      load_contribution
      commit_manuscript
      @generating_pdf = true
      @article_submission.initial_charge.charge_pdf = Pdf.new(:user_id => @article_submission.corresponding_author.user_id, 
                                                   :form_type => 'charge',
                                                   :html_src => render_to_string(:partial=>'charge_sig'))
      
      @article_submission.initial_charge.charge_pdf.generate
      @article_submission.initial_charge.save
      #@article_submission.change_status("article_submission_submitted")
      render :action => 'finished', :id => @article_submission.id  and return
    else
      @message = "" #@article_submission.initial_charge.last_cc_transaction.message
      render :action => 'charge_failed', :id => @article_submission.id and return
    end
  end 
  
  
  def remove_article_submission    
    @article_submission.faux_delete       
    redirect_to :controller=>"manuscripts"
  end
  
  
  def add_coauthor
    if params.has_key?('coauthor_email') and params[:coauthor_email].length >= 9
      @coauthor = User.find_or_initialize_by_email(params[:coauthor_email])
    else
      render :update do |page|
        page << "Invalid Email Address. Please Try Again"
      end
    end
  end
  
   def edit_coauthor
      @coauthor = User.find(params[:coauthor_id])
      render :action=>:add_coauthor
  end
  
  def remove_all_coauthors
      @article_submission.coauthors.clear
      render :update do|page|
         page << "AjaxPopup.OpenBoxWithText($('article_submission_sole_author_1'),true,'All Authors Removed!')"

      end
  end
  
  def update_coauthor
    coa_params= params[:coauthor]
    @coauthor = User.find_or_initialize_by_email(coa_params[:email])  
    info_editable = (@coauthor.user_can_edit == current_user.id && @coauthor.last_login.nil?)
   
    if @coauthor.new_record? or info_editable
      if @coauthor.new_record?
          @coauthor.set_defaults
          @coauthor.set_temp_password
          if current_user
    	      @coauthor.user_can_edit = current_user.id
              @coauthor.create_by_id = current_user.id
          else
	      @coauthor.user_can_edit = 0
              @coauthor.create_by_id  = 0   
          end
	  @coauthor.create_by_ip = request.remote_ip
          
       end
      @coauthor.attributes = coa_params
      unless @coauthor.save
        render :update do |page|
           page.replace_html :ajax_popup_content, :partial => 'add_coauthor_info_long',:locals => { :coauthor => @coauthor, :index => "0" }
         end
         return
      end      
    end
    
    contributions = @article_submission.contributions & @coauthor.contributions
    contribution =  contributions[0] || @article_submission.contributions.new({:user_id =>@coauthor.id, :role_id => 2})
    contribution.first_author = params[:first_author] || false
    @new = contribution.new_record?
    contribution.save!       
    update_contribution_types(contribution,params) 
    email_hash = {:category=>EmailLog::SENT_AUTHOR_COI_REMINDER_INITIAL}
    if  Notifier.deliver_manuscript_coi_link(contribution,email_hash)
     contribution.email_logs.create(email_hash)
    end
    
  end
  
  def send_disclosure_reminder
    contr = Contribution.find_by_article_submission_and_user(@article_submission.id, params[:coauthor_id])
    email_hash = {:category=>EmailLog::SENT_AUTHOR_COI_REMINDER_FROM_AUTHOR}
    if  Notifier.deliver_manuscript_coi_link(contr,email_hash)
     contr.email_logs.create(email_hash)
      msg = "Reminder Successfully Sent"
    else
      msg = "Message Failed To Send. Please Try Again"
    end
     
     link_id = "send_disclosure_#{params[:coauthor_id]}_#{@article_submission.id}"
     render :js =>"AjaxPopup.OpenBoxWithText($('#{link_id}'),true,\"#{msg}\",null)"
  end
  
  def remove_coauthor
      ca = User.find(params[:coauthor_id])
      @article_submission.coauthors.delete(ca)
      render :update do |page|
        page.visual_effect :pulsate, "co_author_#{ca.id}",:duration=>3
        page.remove "co_author_#{ca.id}"
        if @article_submission.coauthors.size == 0
            page.reload
        end
      end
  end
 
  
  
  ################################################################################
  
  private
  

  def load_article_submission
    begin
      @article_submission = ArticleSubmission.find(params[:id])
    rescue
      flash[:notice] = "I could not find your Manuscript Submission."
      redirect_to :action=>'new'
      return
    end
    
    # Ensure they're editing their article and not somebody else's
    if !@article_submission.authors.include?(@user) and !@article_submission.reviewers.include?(@user)
      flash[:notice] = "This is not your article, please submit a new article, or edit your own article submission."
      redirect_to :action => :index
    end

    @title = @article_submission.title 
    @article_submission.mod_by_ip = request.remote_ip
    if current_user
    	@article_submission.mod_by_id = current_user.id    
    else
	@article_submission.mod_by_id = 0   
    end
    
  end
  
  def load_contribution
    @contribution = @article_submission.contribution_by_user_id(@user.id)
  end
  
  def problems_exist
    if @article_submission.problems(@user)
      flash[:notice] = "Your manuscript submission is not complete, please correct the problems and resubmit. Thank you."
      logger.info("Found problems in article_submission: #{@article_submission.id}\n#{@article_submission.problems(@user).join("\n")}")
      return true
    end
    if @user.problems
      flash[:notice] = "Please complete all your personal information before submitting your manuscript."
      return true
    end
    return false
  end
  
  def make_review_pdf
    @article_submission.review_pdf && @article_submission.review_pdf.destroy    # There can be only one
    
    @generating_pdf = true
    @article_submission.review_pdf = Pdf.new(:user_id => @user.id,
                                             :form_type => 'article_submission_review',
                                             :html_src => render_to_string(:action => 'review', :id => @article_submission.id))
    @generating_pdf = false
    
    @article_submission.review_pdf.generate and @article_submission.save
  end
  def send_manuscript_info
    begin
      @article_submission.change_status(ArticleSubmission::SUBMITTED)
      if Notifier.deliver_manuscript_submission_notice(@article_submission)#and @article_submission.notify_coauthors_of_coi
        if Notifier.deliver_manuscript_files(@article_submission)
          logger.info("Manuscript files sent successfully")
        else
          logger.info("!!! There was a problem sending manuscript files")
        end
      else
        flash[:notice] = "There was a problem sending your email summary. Please notify The Oncologist staff."
      end
    rescue
      flash[:notice] = "There was a problem sending your email summary. Please notify The Oncologist staff."
      logger.info("Error occured while emailing summary: #{$!}")
    end   
  end
  
  
  def commit_manuscript
    if @article_submission.commit and @article_submission.save and make_review_pdf
      send_manuscript_info 
      #update_file_versions DON'T NEED B/C WE CREATE A NEW SUBMISSION FOR VERSIONING NOW
      @article_submission.increment_manuscript_rev_num
    else
      flash[:notice] = "There are issues regarding your article submission. Please address these, and resubmit"
      redirect_to :action=>'index', :id=>@article_submission.id
    end
  end
  
  
  
  # Update the contribution types for a specified contribution
  # Given a hash: 'contribution_types' containing the keys: 
  #    contribution_type => { id1, id2, id3... } containing the "public" contribution types
  #    contribution_type_other => N, (N = -1)... indicates that the 'Other' text field is to be used
  #    contribution_type_other_text => "Other Contribution Text String"
  
  def update_contribution_types(contribution, passed_ctypes)
    #   logger.info "--->Updating contribution_types for: #{contribution.id}, types to add: #{passed_ctypes[:contribution_types].join(", ")}"
    # We need to delete all the associations and rebuild them
    contribution.contribution_types.delete_all
    
    # The typical case, they select a 'public' contribution type
    if passed_ctypes.has_key?(:contribution_types)
      #logger.info "---> has key: :contribution_types"
      passed_ctypes[:contribution_types].each do |ctype_id|
        #logger.info "----> processing: ctype: #{ctype_id}"
        ct = ContributionType.find(ctype_id)
        #logger.info "----> found: #{ct}"
        #logger.info "----> existing contribution_types: #{contribution.contribution_types.collect {|ct| ct.id}}"
        contribution.contribution_types << ContributionType.find(ctype_id)
        #logger.info "---> added public contribution_type: #{ctype_id}"
      end
    end
    
    #logger.info "---> c.ctypes #{contribution.contribution_types}"
    
    # The 'Other...' case, ensure we have indeed selected 'Other', and we have text in the 'Other' field
    if passed_ctypes.has_key?(:contribution_type_other) and 
      passed_ctypes[:contribution_type_other] == '-1' and 
      passed_ctypes.has_key?(:contribution_type_other_text) and 
      ! passed_ctypes[:contribution_type_other_text].empty?
      
      # Save the custom contribution type, if not created yet
      ctype_custom = ContributionType.find_or_create_by_title(passed_ctypes[:contribution_type_other_text])
      contribution.contribution_types << ctype_custom
      #logger.info "---> added public contribution_type: #{ctype_custom.id}"
    end
    contribution.save
  end
  
  

  def check_and_update_coauthor_info(coauthor, ca_attributes)
    # If this user was created by the current logged in user, and this user hasn't logged in yet...
    # let this logged in user edit the current users's information
    if (coauthor.user_can_edit == self.current_user.id and coauthor.last_login.nil?)
      coauthor.update_attributes(ca_copy)
    end
  end|
  
def update_file_version(types)
   files = @article_submission.send(types)
   if files.length>1
     current_version = files.sort_by(&:version).last.version
     last_unversioned = files.select{|f|f.version==0}.sort_by(&:id)
     unless last_unversioned.empty?
       last_unversioned.last.update_attribute(:version,current_version+1) 
       files.select{|f|f.version==0}.each do |f|
           f.destroy
       end
     end
   elsif files.length == 1
     file = files.first
     file.update_attribute(:version,1)
   end
   
end

def update_additional_files_version
     files = @article_submission.additional_files
     last_versioned = files.sort_by(&:version).last
     current_version = last_versioned ? last_versioned.version : 0
     unversioned = files.select{|f|f.version==0}
     unversioned.each do |u|
         u.update_attribute(:version,current_version+1)
     end
end
 
def update_file_versions
    [:manuscripts,:cover_letters,:permissions].each do |type|
      update_file_version(type)
    end
     update_additional_files_version
end


  
  
end
