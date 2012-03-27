class ArticleSubmissionsController < ApplicationController
  layout "application"

  #  before_filter :dump_request
  before_filter :login_required
  #before_filter :load_user
  #  before_filter :enforce_destiny, :only => [:new, :create] 
  
  before_filter :load_article_submission, :except => [:new, :create, :add_coauthor, :remove_coauthor, :add_reviewing_instance,
                                                      :remove_reviewing_instance ]
  
  before_filter :must_be_corresponding_author, :except => [:new, :create, :add_coauthor, :remove_coauthor, :add_reviewing_instance,
                                                      :remove_reviewing_instance]
  
  before_filter :load_contribution, :only => [:show, :general, :update, :coauthors, :update_coauthors,
                                              :review, :finished, :update_review, :update_copyright, :credit_card]
  
  def index
    redirect_to :action=>:general
  end
  
  def new
    @article_submission = ArticleSubmission.new
    type = ManuscriptType.find_by_id(params[:type_id])
    @article_submission.manuscript_type =  type
    @article_submission.manuscript_type_id = type.id if type
    @article_submission.form_state = :general
    @contribution = @article_submission.contributions.new
  end
  
  def create
    @article_submission = ArticleSubmission.new(params[:article_submission])
    @article_submission.create_by_ip = request.remote_ip
    if current_user
	@article_submission.create_by_id = current_user.id    
    else
	@article_submission.create_by_id = 0   
    end
    
    @article_submission.form_state = :general
    @contribution = Contribution.new
    has_contr = params.has_key?(:contribution_types) || !params[:contribution_type_other].blank?
    if @article_submission.valid? && has_contr 
        @article_submission.save
        @article_submission.change_status("article_submission_started")
        @contribution.article_submission_id = @article_submission.id
        @contribution.user_id = @user.id
        @contribution.role_id = 1
      if update_contribution_types(@contribution, params) and @contribution.save
        redirect_to :action => where_to, :id => @article_submission.id
        return
      else
        @article_submission.destroy
      end
    end
    
     if @article_submission.errors && !has_contr
        @article_submission.errors.add_to_base("You must enter a contribution type")
     elsif !has_contr
        flash[:error] = "You must enter a contribution type"
     end
      
     type = ManuscriptType.find_by_id(params[:article_submission][:manuscript_type_id])
     @article_submission.manuscript_type =  type
     render :action => "new"
  end

  def edit
    redirect_to :controller => :manuscripts, :action => :edit, :id => @article_submission.id  
  end
  
   def download_files
     file = FileSender.get_zip_file(@article_submission)
     send_file file
  end
  def general
    @article_submission.form_state = :general
  end
  
  def update
    @article_submission.form_state = :general
    if @article_submission.update_attributes(params[:article_submission]) and update_contribution_types(@contribution, params) and @contribution.save
      redirect_to :action => where_to, :id => @article_submission.id
      return
    else
        type = ManuscriptType.find_by_id(params[:article_submission][:manuscript_type_id])
        @article_submission.manuscript_type =  type
        @article_submission.manuscript_type_id = type.id if type
      render :action => "general"
    end
  end
  
  def coauthors
    #logger.info("in coauthors method")
    #logger.info("ca=#{@article_submission.corresponding_author.full_name}")
    #logger.info("current user=#{current_user.full_name}")
    @article_submission.form_state = :coauthors
    @coauthors = @article_submission.coauthors
  end
  
  # Accept an email address of a coauthor
  def add_coauthor
    if params.has_key?('coauthor_email') and params[:coauthor_email].length >= 9
      @coauthor = User.find_or_initialize_by_email(params[:coauthor_email])
    else
      render :update do |page|
        page['add_coauthor_message'].replace("<div id='add_coauthor_message>Not a valid email address</div>")
        page['link'].show
        page['spinner'].hide
      end
    end
  end
  
  def update_coauthors
    @article_submission.form_state = :coauthors
    @article_submission.update_attributes(:visited_coauthor_page=>true)
    # Ensure given coauthors are valid
    # and load the @coauthors array we'll use in the view, in case something goes wrong
    if params.has_key?(:coauthors)
      errors_found = false
      errors = []
      @coauthors = []
      params[:coauthors].each do |ca_array|
        ca = ca_array[1].clone # For some reason the data is a hash in the 2nd field of the array
        ca.delete('contribution_type_other_text')
        ca.delete('contribution_type_other')
        ca.delete('contribution_types')
        ca.delete('first_author')
        coauthor = User.find_or_initialize_by_email(ca[:email])
        #logger.info("Found coauthor id: #{coauthor.id}")
  
        @coauthors << coauthor
  
        # Don't modify author attributes unless we're an existing record, or we created this user and they haven't verified their info
        unless coauthor.new_record? or coauthor.user_can_edit == current_user.id
          next
        end
        if coauthor.new_record?
          coauthor.set_defaults
          coauthor.set_temp_password
	   if current_user
	        coauthor.user_can_edit = current_user.id    
	   else
		coauthor.user_can_edit = 0   
	   end
	  
        end
        
        # Update coauthor with given info
        coauthor.attributes = ca
        
        unless coauthor.valid?
          errors_found = true
          errors << coauthor.errors 
        end
      end
      if errors.size > 0
        #logger.info "Errors: #{errors.inspect}"
        flash[:notice] = "Your coauthors could not be updated. Please correct the following problems and resubmit."
        render :action=>'coauthors'
        return
      end
    else
      @coauthors = @article_submission.coauthors      
    end
    
    
    
    # Remove any coauthor associations
    original_coauthors_emails = @article_submission.coauthors.collect {|ca| ca.email}
    #logger.info "---> orig_coauth_emails: #{original_coauthors_emails.join(", ")}"
    
    # Now, Rebuild the coauthor associations
    coauthors_to_delete = original_coauthors_emails.clone
    
    # Ensure these, and only these coauthors POST'd are associated with this article_submission
    # We don't want to destroy the user though, in case it's associated with another article
    if params.has_key?(:coauthors)
      new_coauthors_emails = params[:coauthors].collect {|ca| ca[1][:email]}
      coauthors_to_create = new_coauthors_emails.clone
      
      # don't create any we already have, so remove the ones we have from the creation list
      original_coauthors_emails.each do |email|
        coauthors_to_create.delete(email)
      end
      
      # Ensure we're not adding ourselves
      if coauthors_to_delete.include?(@article_submission.corresponding_author.email)
        coauthors_to_delete(@article_submission.corresponding_author.email)
      end
      
      # don't delete any we want to create, so remove the ones we want from the delete list
      new_coauthors_emails.each do |email|
        coauthors_to_delete.delete(email)
      end
      
#      logger.info "---> after reduction"      
#      logger.info "---> coauthors_to_delete: #{coauthors_to_delete.join(", ")}"
#      logger.info "---> coauthors_to_create: #{coauthors_to_create.join(", ")}"
      
      article_submission_contributions = @article_submission.contributions
      params[:coauthors].each do |ca_array|
        ca = ca_array[1] # For some reason the data is a hash in the 2nd field of the array
        
#        logger.info "---> Considering ca email: #{ca[:email]}"
        user = nil
        contribution = nil
        
        if coauthors_to_create.include?(ca[:email])
          #logger.info "---> Looking for existence of: #{ca[:email]}"
          # Does this coauthor exist? check by email, if not create them
          if (user = User.find_by_email(ca[:email]))
            #logger.info "---> User exists, id: #{user.id}"
           
          else            
            #logger.info "---> Couldn't find user, need to create"
            #user = User.new({:first_name => ca[:first_name], 
            #  :last_name => ca[:last_name],
            #  :email => ca[:email],
            #  :pre_title => ca[:pre_title],
            user = User.new(:user_can_edit => self.current_user.id)

            # protect these attributes
            remove_ca_attributes(ca_copy = ca.clone)

            user.update_attributes(ca_copy)
            user.update_attributes({
              :create_by_id => self.current_user.id,
              :auto_created => true,
              :user_can_edit => self.current_user.id})
            user.create_by_ip = request.remote_ip
            if current_user
	    	user.create_by_id = current_user.id    
   	    else
		user.create_by_id = 0   
    	    end
	    
            user.set_temp_password
            
            unless user.save()
              @user = user
              flash.now[:notice] = "There was a problem updating your Co-Authors. Please correct any problems, and try again. (Error# 1)"
              logger.info "debug !!!! Problem creating new user: #{user.first_name}"
              render :action => :coauthors
              return
            end
            #logger.info "--->  User didn't exist, so created: #{user.id}"
          end    
        end
        
        user ||= User.find_by_email(ca[:email])

        # Update coauthor info if the current user has privileges
        check_and_update_coauthor_info(user, ca) 

        # Find the contribution associated with this user and article_submission, if it already exists
        contributions = article_submission_contributions & user.contributions
        contribution = (contributions.size > 0) ? contributions[0] : nil        
        
        # If we don't have a contribution associated with this article_submission / user, then create one
        contribution ||= @article_submission.contributions.create({:user_id => user.id, :role_id => 2})
        logger.info("**********************************")
        logger.info(ca[:first_author])
        contribution.first_author = ca[:first_author] || false
        if ! contribution.save
          flash[:notice] = "There was a problem updating your Co-Authors. Please correct any problems, and try again. (Error# 2)"
          render :action => :coauthors
          return
        end
        
        update_contribution_types(contribution, ca)
        
      end # End params[:coauthors]
    end    
    
    # delete the unwanted co-authors
    #logger.info "---> Going to delete the unwanted co-authors..."
    @article_submission.coauthors.each do |ca|
      if coauthors_to_delete.include?(ca.email)
        @article_submission.coauthors.delete(ca)
      end
    end
    
    redirect_to :action => where_to, :id => @article_submission.id
    return
  end
  
  def reviewers
    @article_submission.form_state = :reviewers
  end
  
  def add_reviewing_instance
#    @reviewing_instance = ReviewingInstance.new
#    @reviewing_instance.user = User.new
  end
  
  def update_reviewers
    @article_submission.form_state = :reviewers

    #logger.info("***** #{params.inspect}")
    [1,2,3].each do |n|
      @article_submission.write_attribute_3("reviewer#{n}".to_sym, params["reviewer#{n}"])
      #logger.info("***** writing reviewer#{n} info: #{@article_submission.send('reviewer'+n.to_s).inspect} params: #{params['reviewer' + n.to_s]} ***")
    end
    
    
    if @article_submission.save and @article_submission.reviewers_valid?
      redirect_to :action => where_to, :id => @article_submission.id
    else
      flash[:notice] = "Please complete all the fields for each reviewer you choose to add."
      redirect_to :action => :reviewers, :id => @article_submission.id
    end
    return
  end
  
  def author_resp
    @article_submission.form_state = :author_resp
  end
  
  def update_author_resp
    @article_submission.form_state = :author_resp
    if ! @article_submission.update_attributes(params[:article_submission])
      logger.info "debug: !!!!Problem updating article_submission - author_resp"
      render :action => :author_resp, :id => @article_submission.id
      return
    end
    redirect_to :action => where_to, :id => @article_submission.id
    return
  end
  
  def fees
    @article_submission.form_state = :fees
  end
  
  def update_fees
    @article_submission.form_state = :fees
    redirect_to :action => fees unless request.post?
    
    if params[:article_submission][:invited] == '0'
      params[:article_submission].delete(:invited)
      @article_submission.invited = 0
    end
    no_problems = true
    @article_submission.update_attributes(params[:article_submission]) or no_problems = false

    if no_problems
      redirect_to :action => where_to, :id => @article_submission.id
    else
      render :action => :fees
    end
  end
  
  def checklist
    @article_submission.form_state = :checklist
  end
  
  def update_checklist
    @article_submission.form_state = :checklist    
    if @article_submission.update_attributes(params[:article_submission])
      
      # Only use our lookup table if we're going back
      if params[:previous] or params[:prev]
        redirect_to :action=>where_to, :id => @article_submission.id
      else
        redirect_to :controller => 'manuscripts', :action => 'edit', :id => @article_submission.id
      end
      return
    end
    render :action => :checklist
  end
  
  
  
  #  def destroy
  #    @article_submission = ArticleSubmission.find(params[:id])
  #    @article_submission.destroy
  #      redirect_to(article_submissions_url)
  #    end
  #  end
  
  def upload_manuscript
    new_manuscript = Manuscript.new(params[:manuscript])
    if @article_submission.manuscripts << new_manuscript
      flash[:notice] = "Your manuscript was added successfully"
#      if(@article_submission.provisionally_accepted)
#         @article_submission.change_status(ArticleSubmission::MANUSCRIPT_RESUBMITTED)
#      end
    else
      flash[:notice] = "There was a problem added your manuscript"
    end
    redirect_back_or('manuscripts')
  end
  
  def remove_manuscript
    manuscript = Manuscript.find(params[:manuscript_id])
    if (manuscript.destroy)
      flash[:notice] = "Your manuscript was removed successfully."
    else
      flash[:notice] = "There was a problem removing the manuscript."
    end
    redirect_back_or('manuscripts')
  end
  
  def upload_cover_letter
    new_cover_letter = CoverLetter.new(params[:cover_letter])   
    if @article_submission.cover_letters << new_cover_letter
      flash[:notice] = "Your cover letter was added successfully."
#      if(@article_submission.provisionally_accepted)
#          @article_submission.change_status(ArticleSubmission::COVER_LETTER_RESUBMITTED)
#      end
      #old_cover_letter and old_cover_letter.destroy
    else
      flash[:notice] = "There was a problem adding your cover letter"
    end
    redirect_back_or('manuscripts')
  end
  
  def remove_cover_letter
    cover_letter = CoverLetter.find(params[:cover_letter_id])
    if (cover_letter.destroy)
      flash[:notice] = "The cover letter was removed successfully."
    else
      flash[:notice] = "There was a problem removing the cover letter."
    end
    redirect_back_or('manuscripts')
  end
  
   def upload_permissions
    new_permission = Permission.new(params[:permission])
    if @article_submission.permissions << new_permission
      flash[:notice] = "Your permissions file was added successfully."
    else
      flash[:notice] = "There was a problem adding your permissions file"
    end
     redirect_back_or('manuscripts')
  end
  
  def remove_permissions
    permission = Permission.find(params[:permission_id])
    if (@article_submission.permission.destroy)
      flash[:notice] = "The permissions file was removed successfully."
    else
      flash[:notice] = "There was a problem removing the permissions file."
    end
    redirect_back_or('manuscripts')
  end
  
  
  
  def upload_video_link 
     @article_submission.manuscript_video_link = params[:manuscript_video_link] if params[:manuscript_video_link]
     url = @article_submission.manuscript_video_link 
     unless url=~/^http[s]?:\/\/.+$/
        url = "http://" + url
      end
     @article_submission.manuscript_video_link = url
     @article_submission.save!
     render :js =>"$('video_link_div').innerHTML = 'Video Link: <a href=\"#{@article_submission.manuscript_video_link}\">#{@article_submission.manuscript_video_link}<a>'"  
  end
 
 def remove_video_link
   @article_submission.manuscript_video_link = nil
   @article_submission.save!
     render :text=>"Please Enter A Video Link"
 end
  
  
  def upload_additional_file
    ad = AdditionalFile.new(params[:additional_file])
    
    if @article_submission.additional_files << ad and @article_submission.save! and ad.save!
      flash[:notice] = "The file was added successfully."
    else
      logger.info("****** There was a problem adding the additional file to the submission ******")
      logger.info("****** @article_submission.errors.inspect: #{@article_submission.errors.inspect}")
      logger.info("****** ad.errors.inspect: #{ad.errors.inspect}")
      flash[:notice] = "There was a problem adding the file."
    end
    redirect_back_or('manuscripts')
  end
  
  def remove_additional_file
    af = AdditionalFile.find(params[:additional_file_id].to_i)  
    if(af.destroy)
      flash[:notice] = "File was removed successfully."
    else
      flash[:notice] = "There was a problem removing the additional file."
    end
    redirect_back_or('manuscripts')
  end
  
  
  ######################################################################################
  ######################################################################################
  ######################################################################################
  ######################################################################################
  ######################################################################################
  
  
  private
  
  def enforce_destiny
    if (u = @user.article_submissions.find_by_committed(nil))
      flash[:notice] = "You have an existing Manuscript Submission Form"
      redirect_to :action=>'general', :id=>u.id
    end
  end
  
  def load_article_submission
    begin
      @article_submission = ArticleSubmission.find(params[:id])
    rescue
      flash[:notice] = "I could not find your Manuscript Submission."
      redirect_to :action=>'new'
      return
    end
    
    # Ensure they're editing their article and not somebody else's
    if ! @user.article_submissions.include?(@article_submission)
      flash[:notice] = "This is not your article, please submit a new article, or edit your own article submission."
      redirect_to :controller => :home
    end
    
    @article_submission.mod_by_ip = request.remote_ip
    if current_user
    	@article_submission.mod_by_id = current_user.id    
    else
	@article_submission.mod_by_id = 0   
    end

  end
  
  def must_be_corresponding_author
    if current_user != @article_submission.corresponding_author
      redirect_to :controller=>'home'
    end
  end
  
  def load_contribution
    @contribution = @article_submission.contribution_by_user_id(@user.id)
  end
  
  def where_to
    if params[:previous] or params[:prev]
      fs = @article_submission.form_state
      prev = @article_submission.sections(fs)[:prev]
      #logger.info("---> going to previous action: #{prev}")
      return prev
    elsif params[:save]
     return  'edit'
     #return @article_submission.form_state
    else
      fs = @article_submission.form_state
      next_action = @article_submission.sections(fs)[:next]
      #logger.info("---> going to next action: #{next_action}")
      return next_action
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
  
  def dump_request
    #    render :text => request.inspect
    render :text => request['parameters'].action
  end


  def remove_ca_attributes(attributes)
    attributes ||= {}
    [:first_author,:create_by_id, :auto_created, :user_can_edit, :contribution_type_other_text, :contribution_type_other, :contribution_types].each {|a| attributes.delete(a)}
    attributes
  end
 
  def check_and_update_coauthor_info(coauthor, ca_attributes)
            # If this user was created by the current logged in user, and this user hasn't logged in yet...
            # let this logged in user edit the current users's information
            if (coauthor.user_can_edit == self.current_user.id and coauthor.last_login.nil?)
             # logger.info "---> Creator is logged in, overwrite user info"

              ca_copy = ca_attributes.clone

              # protect these attributes
              remove_ca_attributes(ca_copy)

              coauthor.update_attributes(ca_copy)
              #user.update_attributes({:first_name => ca[:first_name], 
              #  :last_name => ca[:last_name],
              #  :email => ca[:email],
              #  :pre_title => ca[:pre_title]})
            end
  end
  
end
