class BlanketCoiFormsController < ApplicationController
  
  before_filter :login_required, :except => :direct
 
  # now done in application controller 
  #before_filter :load_user, :except => [:direct,:definitions]
  before_filter :load_coi_form, :except => [:new, :init, :index,:definitions, :thank_you]
  
  before_filter :check_access, :except => [:new, :init, :index, :direct,:definitions, :thank_you]
  before_filter :must_be_admin, :only => [:index]
  
  protect_from_forgery :only => [:update, :review, :edit] 
  
  def new
    # Don't create another form if they haven't submitted their latest one
    @existing_coi_form = @user.latest_blanket_coi_form
    
    if @existing_coi_form and @existing_coi_form.committed
      @coi_form = @existing_coi_form.create_an_update
      @coi_form.save
      logger.info("existing coi form is saved, creating new one")
    elsif @existing_coi_form
      @coi_form = @existing_coi_form
      logger.info("existing coi form is not saved")
    else
      @coi_form = BlanketCoiForm.create(:user_id => @user.id)
      logger.info("no existing coi, creating a new one")
      if @coi_form.new_record?
        flash[:notice] = "There was a problem creating your COI form."
        redirect_to :controller=>'home', :action=>'error'
        return
      end
    end
    render :action => :edit
  end
  
  # Init a new COI form for the user, and pass them to the edit page of the form
  def init
    @coi_form = BlanketCoiForm.new
    @coi_form.user_d = @user.id

    # They may have already filled out a COI form
    if @existing_coi_form = BlanketCoiForm.find(:first, :conditions=>{:user_id=>@user.id}, :order=>'version DESC')
      
      # They haven't finished their last form, redirect to edit that one
      if ! @existing_coi_form.committed
        redirect_to :action => 'edit', :id=>@existing_coi_form.id
        return
        
      # This is a new version of the same form, populate with the old form's data, and increment the version
      else
        @coi_form = @existing_coi_form.create_an_update
      end
    end
    
    if @coi_form.save
      render :action => "edit", :id=>@coi_form.id
    else
      flash[:notice] = "There was a problem creating your COI form."
      redirect_to :controller=>'home', :action=>"error"
    end
  end

  # They have a direct link to this form. Use the token to find their form.
  def direct
    if ! @coi_form
      flash[:notice] = "Your Financial Disclosure form was not found. Please check the link, and try again."
      redirect_to :controller => 'home', :action=>'error'
    elsif @coi_form.committed
      logger.info("*** coi_forms/direct with id: #{@coi_form.id} has already been committed!")
      flash[:notice] = "This Financial Disclosure form has already been submitted."
      redirect_to :controller=>'home', :action=>'error'
      return
    end
    
    self.current_user = @coi_form.user     # Sign them in
    flash[:notice] = "Your Financial Disclosure form has been found, and you are begin signed in now."
    redirect_to :action=>'edit', :id=>coi_form.id
  end


  def edit
    
    
  end

  def update
    @coi_form.form_state = :updating
    
    if @coi_form.update_attributes(params[:coi_form])
      redirect_to :action => "review", :id=>@coi_form.id
    else
      render :action => "edit", :id=>@coi_form.id
    end
  end
  
  def review
    
  end

  def thank_you
  end
  
  
  def commit
    @coi_form.form_state = :commit
    
    if @coi_form.update_attributes(params[:coi_form]) and @coi_form.commit and @coi_form.save and make_pdf
     # flash[:notice] = "Your Financial Disclosure form has been updated. Thank you. "
      begin
        if Notifier.deliver_blanket_coi_notice(@coi_form.user)
          #flash[:notice] << "A notice has been sent to the Corresponding Author regarding the completion of this COI form"
        else
          #flash[:notice] << "There was a problem sending the notice to the Corresponding Author regarding the completion of this COI form"
        end
      rescue
        #flash[:notice] << "There was a problem sending the notice to the Corresponding Author regarding the completion of this COI form"
        logger.info("An error occurred while sending the COI notice email: #{$!}")
       redirect_to :controller=>'home', :action=>'error'
        return
      end
      redirect_to :action=>'thank_you'
      return
    end
    flash.now[:notice] = "There was a problem saving your Financial Disclosure form. Please ensure you have signed the form, and all your answers are complete. Thank you."
    render :action=>'review'
  end
  
  def delete
    @coi_form.destroy
    redirect_to :controller=>'users', :action=>'manuscripts'
    return
  end
  
  def definitions
    
  end
  
  
  private
  
  def load_coi_form
    if params.has_key?('t')
      @coi_form = BlanketCoiForm.find_by_token(params[:t])
    elsif params.has_key?('id')
      @coi_form = BlanketCoiForm.find(params[:id])
    end
    unless @coi_form
      flash[:notice] = "Could not find your COI form"
      redirect_to :controller=>'home', :action=>'error'
    end
  end
  
  # Now done in application controller 
  #def load_user
  #  if current_user.has_admin? and params.has_key?("user_id")
  #    @user = User.find(params[:user_id])
  #  else
  #    @user = current_user
  #  end
  #  unless @user
  #    flash[:notice] = "Could not find the current or specified user"
  #    redirect_to :controller => "home", :action=>'error'
  #  end   
  #end
  
  def check_access
   if @coi_form.user != @user and ! current_user.has_admin?
      @coi_form = nil
      flash[:notice] = "You are not authorized to access this COI form"
      redirect_to :controller=>'home',:action=>'error'
      return
    end
  end

  def make_pdf
    @generating_pdf = true
    @coi_form.pdf = Pdf.new(:user_id => @user.id,
                            :form_type => 'blanket_coi_form',
                            :html_src => render_to_string(:action => 'review', :id => @coi_form.id))

    @generating_pdf = false
    @coi_form.pdf.generate and @coi_form.save
  end  
end
