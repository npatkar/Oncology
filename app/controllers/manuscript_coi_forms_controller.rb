class ManuscriptCoiFormsController < ApplicationController
  
  before_filter :login_required, :except => :direct
  before_filter :load_proper_id_type
  #before_filter :load_user, :except => :direct
  before_filter :load_coi_form, :except => [:new, :init, :direct, :index,:regenerate_pdfs,:regenerate_pdf]
  before_filter :must_be_admin, :only => [:index,:regenerate_pdfs,:regenerate_pdf]
  
  protect_from_forgery :only => [:update, :review, :edit] 
  
  
  public
  
  
  def index
  end
  
  def new
    @coi_form = ManuscriptCoiForm.create({@id_type => @id_value})
    redirect_to :action => :edit, :id => @coi_form.id
  end
  
  
  def init
    # Look for an existing COI form for this contribution    
    @existing_coi_form = ManuscriptCoiForm.find(:first, :conditions=>{@id_type => @id_value}, :order=>'version DESC')
    # If no existing form, create one
    if @existing_coi_form.nil?
      @coi_form = ManuscriptCoiForm.create({@id_type=> @id_value})
      @parent = @coi_form.contribution || @coi_form.article_submission_reviewer
      # They haven't finished their last form with this manuscript, redirect to edit that one
    else
      if ! @existing_coi_form.committed     
        redirect_to :action => 'edit', :id=>@existing_coi_form.id
        return
        # This is a new version of the same form, populate with the old form's data, and increment the version
      else
        @coi_form = @existing_coi_form.create_an_update
      end
    end
   
    if @coi_form.save
       Rails.logger.info(@coi_form.attributes.inspect)
      @parent = @coi_form.contribution || @coi_form.article_submission_reviewer
      render :action => "edit", :id=>@coi_form.id
    else
      render :controller=>'users', :action=>"manuscripts"
    end    
  end
  
  
  def direct
    token = params[:t]
    contribution = Contribution.find_by_coi_token(token)
    if contribution.nil?
      flash[:notice] = "I could not find your Financial Disclosure form. Please check the link, and try again."
    else
      logger.info("*** coi_forms/direct found contribution with id: #{contribution.id}")
      self.current_user = contribution.user     # Sign them in
      if coi_form = ManuscriptCoiForm.find(:first, :conditions=>{:contribution_id=>contribution.id}, :order=>"version DESC")
        flash[:notice] = "Your Financial Disclosure form has been found, and you are begin signed in now."
        redirect_to :action=>'edit', :id=>coi_form.id
        return
      else
        flash[:notice] = "Your Conflict of Interset form was not found. Please check the link, and try again."
      end
    end
    redirect_to :controller=>'home'
    return
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
  
  
  def commit
    @coi_form.form_state = :commit  
    if @coi_form.update_attributes(params[:coi_form]) and @coi_form.commit and @coi_form.save and make_pdf
      flash[:notice] = "Your Financial Disclosure form has been updated. Thank you. "    
      begin
        email_sent = false
        if @parent.instance_of?ArticleSubmissionReviewer
          email_hash = Hash.new
          email_sent = ReviewerNotifications.deliver_reviewer_coi_notice(@parent, email_hash)
          @parent.email_logs << EmailLog.create(email_hash) if email_sent
        else    
          email_sent = Notifier.deliver_manuscript_coi_notice @coi_form
          if email_sent
            flash[:notice] << "A notice has been sent to the Corresponding Author regarding the completion of this COI form"
          else
            flash[:notice] << "There was a problem sending the notice to the Corresponding Author regarding the completion of this COI form."
          end
        end     
        
      rescue 
        unless @parent.instance_of?ArticleSubmissionReviewer
          flash[:notice] << "There was a problem sending the notice to the Corresponding Author regarding the completion of this COI form"
        end
      end
      
      redirect_to :controller=>'manuscripts'
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
  
   def regenerate_pdf
      @parent = Contribution.find(params[:id])
      @coi_form = @parent.latest_committed_manuscript_coi_form   
     # @parent = @coi_form.contribution || @coi_form.article_submission_reviewer
      @generating_pdf = true
      @coi_form.pdf = Pdf.new(:user_id => @parent.user.id,
                            :form_type => 'manuscript_coi_form',
                            :html_src => render_to_string(:action => 'review', :id => @coi_form.id))
      @generating_pdf = false
      
      @coi_form.pdf.generate && @coi_form.save
      raise @coi_form.pdf.id.to_s
    end
  
  
  def regenerate_pdfs
    forms = ManuscriptCoiForm.find(:all,:having=>"create_date > '2010-11-18' and commited = true")
    ids = Array.new
    forms.each do |coi_form_i|
      begin
      	@coi_form = coi_form_i
        @parent = @coi_form.contribution || @coi_form.article_submission_reviewer
        Rails.logger.info("*********Converting:#{@coi_form.id}- #{@coi_form.create_date} - #{@parent.article_submission.title}-#{@parent.article_submission.id}*******************")
        @generating_pdf = true    
        old_pdf = @coi_form.pdf
        if old_pdf
          old_pdf.coi_form = nil
          old_pdf.destroy
        end
        begin
          @coi_form.pdf = Pdf.new(:user_id => @parent.user.id,
                            :form_type => 'manuscript_coi_form',
                            :html_src => render_to_string(:action => 'review', :id => @coi_form.id))
        rescue
          Rails.logger.info("#{@coi_form.id} screwed up !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
          next
        end
        @generating_pdf = false
        
        @coi_form.pdf.generate && @coi_form.save
        ids << @coi_form.pdf.id
      rescue Exception=>e
        Rails.logger.info("Conversion Error *******#{e}*******")
      end
    end
    
    render :text=>ids.join("<br/>")
  end
  
  private
  
  def load_coi_form
    @coi_form = ManuscriptCoiForm.find(params[:id])
    
    @parent = @coi_form.contribution || @coi_form.article_submission_reviewer
    
    if @coi_form.user != @user and @coi_form.article_submission.corresponding_author != @user
      @coi_form = nil
      flash[:notice] = "You are not authorized to access this COI form"
      redirect_to :controller=>'manuscripts', :action => 'edit', :id => @coi_form.article_submission.id
      return
    end
    
    @status = @parent.instance_of?(ArticleSubmissionReviewer) ? "review" : "co_author"
  end
  
  def load_proper_id_type
    @id_type = ''
    @id_value = ''
    if(params[:article_submission_reviewer_id])
      @id_type = 'article_submission_reviewer_id'
      @id_value = params[:article_submission_reviewer_id]
    else
      @id_type = 'contribution_id'
      @id_value = params[:contribution_id]
    end    
  end
  
  
  def make_pdf
    @generating_pdf = true
    @coi_form.pdf = Pdf.new(:user_id => @user.id,
                            :form_type => 'manuscript_coi_form',
                            :html_src => render_to_string(:action => 'review', :id => @coi_form.id))
    @generating_pdf = false
    
    @coi_form.pdf.generate and @coi_form.save
  end
end
