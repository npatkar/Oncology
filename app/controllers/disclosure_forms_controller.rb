class DisclosureFormsController < ApplicationController
  
  before_filter :login_required
  #before_filter :load_user
  
  protect_from_forgery :only => [:create, :update, :review, :edit]
  
  def commit
    if @disclosure_form.update_attributes(params[:disclosure_form]) and @disclosure_form.commit and @disclosure_form.save
      flash[:notice] = "Your author disclosure form has been updated. Thank you."
      redirect_to :controller=>'users', :action=>'manuscripts'
    else
      flash.now[:notice] = "There was a problem saving your disclosure form. Please ensure you have signed the form, and all your answers are complete. Thank you."
      render :action=>'review'
    end
  end
end
