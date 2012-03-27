class FormsController < ApplicationController
  
  before_filter :login_required
  #before_filter :load_user
  before_filter :load_contribution, :only => [:author_responsibilities, :copyright_assignment, :update_author_responsibilities, :update_copyright_assignment, :author_responsibilities_pdf]

  def author_responsibilities
     @contribution.form_state = :author_resp
  end



  def update_author_responsibilities
    @contribution.form_state = :author_resp
    @contribution.responsibilities_sig_time = Time.now   # Set the sig time to now, just in case it validates and saves
    
    if @contribution.update_attributes(params[:contribution])
      @contribution.responsibilities_pdf && @contribution.responsibilities_pdf.destroy

      @generating_pdf = true
      @contribution.responsibilities_pdf = Pdf.new(:user_id => @contribution.user_id, 
                                                   :form_type => 'author_responsibilities',
                                                   :html_src => render_to_string(:action => 'author_responsibilities_pdf', :contribution_id => @contribution_id))
      @generating_pdf = false

      if @contribution.responsibilities_pdf.generate and @contribution.save
        redirect_to :controller => 'manuscripts'
        return
      end
      logger.info "debug: !!!!Problem generating responsibilities pdf and saving contribution"
    end
    logger.info "debug: !!!!Problem updating contribution - author_resp"
    render :action => :author_responsibilities, :contribution_id => @contribution.id
    return
  end



  def copyright_assignment
    @contribution.form_state = :copyright
  end
 

 
   def update_copyright_assignment
    @contribution.form_state = :copyright
    @contribution.copyright_sig_time = Time.now   # Set the sig time to now, just in case it validates and saves
    
    if @contribution.update_attributes(params[:contribution])
      @contribution.copyright_pdf && @contribution.copyright_pdf.destroy

      @generating_pdf = true
      @contribution.copyright_pdf = Pdf.new(:user_id => @contribution.user_id,
                                            :form_type => 'copyright_assignment',
                                            :html_src => render_to_string(:action => 'copyright_assignment', :contribution_id => @contribution_id))
      @generating_pdf = false

      if @contribution.copyright_pdf.generate and @contribution.save
        redirect_to :controller => 'manuscripts'
        return
      end
      logger.info "debug: !!!!Problem generating copyright pdf and saving contribution"
    end

    logger.info "debug: !!!!Problem updating contribution - copyright_assignment"
    render :action => :copyright_assignment, :contribution_id => @contribution.id
    return
  end
  
  
  private
  
  def load_contribution
    begin
      @contribution = Contribution.find(params[:contribution_id])
    rescue
      flash[:notice] = "I could not find your Manuscript."
      redirect_to :controller=>'contributions', :action=>'new'
      return
    end
    
    @contribution.mod_by_ip = request.remote_ip
    if current_user
    	@contribution.mod_by_id = current_user.id    
    else
	@contribution.mod_by_id = 0   
    end
    @contribution.user_id == @user.id   # we can only update our own contributions
  end
end
