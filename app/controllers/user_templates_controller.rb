class UserTemplatesController < ApplicationController
  
  before_filter :must_be_admin
  
  # GET /user_templates
  # GET /user_templates.xml
  def index
    sort =  params[:sort] || 'title'
    @user_templates = UserTemplate.find(:all, :order=>sort)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_templates }
    end
    add_audit_trail(:details => "Viewed template listing.")
  end

  # GET /user_templates/1
  # GET /user_templates/1.xml
  def show
    @user_template = UserTemplate.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_template }
    end
    add_audit_trail(:details => "Viewed a template with alias: #{@user_template.alias}")
  end

  # GET /user_templates/new
  # GET /user_templates/new.xml
  def new
    @user_template = UserTemplate.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_template }
    end
  end

  # GET /user_templates/1/edit
  def edit
    set_html_edit
    if params.has_key?(:id)
      @user_template = UserTemplate.find(params[:id])
    elsif params.has_key?(:template_alias)
      @user_template = UserTemplate.find_by_alias(params[:template_alias])
    else
      @user_template = nil
    end
    
    add_audit_trail(:details => "Editing a template with alias: #{@user_template.alias}")
  end

  def edit_inline
    @user_template = UserTemplate.find_by_alias(params[:template_alias])
    set_html_edit
    render :layout => false
    add_audit_trail(:details => "Editing a template with alias: #{params[:template_alias]}")
  end

  # POST /user_templates
  # POST /user_templates.xml
  def create
    @user_template = UserTemplate.new(params[:user_template])
    respond_to do |format|
      if @user_template.save
        flash[:notice] = "Template '#{@user_template.title}' was successfully created."
        format.html { redirect_to(user_templates_url) }
        format.xml  { render :xml => @user_template, :status => :created, :location => @user_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_template.errors, :status => :unprocessable_entity }
      end
    end
    add_audit_trail(:details => "Created a template with alias: #{@user_template.alias}")
  end

  # PUT /user_templates/1
  # PUT /user_templates/1.xml
  def update
    @user_template = UserTemplate.find_or_initialize_by_alias(params[:user_template][:alias])
    #logger.info(params[:user_template])
    #logger.info("----------------")
    respond_to do |format|
      if @user_template.update_attributes(params[:user_template])
        flash[:notice] = "Template '#{@user_template.title}' was successfully updated."
        format.html { redirect_to(user_templates_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_template.errors, :status => :unprocessable_entity }
      end
    end
    # remove the stale template info from the cache
    UserTemplate.clear_template_cache(@user_template.alias)
    add_audit_trail(:details => "Updated a template with alias: #{@user_template.alias}")
  end
 
  def clear_template_cache
    UserTemplate.clear_template_cache
    flash[:notice] = "Template Cache was successfully cleared."
    redirect_to :action => :index
  end

  def clone_template
    @user_template = UserTemplate.find(params[:id]).clone
    @user_template.title += ' - Copy'
    @user_template.alias += '_copy'

    respond_to do |format|
      if @user_template.update_attributes(params[:user_template])
        flash[:notice] = "Template '#{@user_template.title}' was successfully updated."
        format.html { redirect_to(user_templates_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_template.errors, :status => :unprocessable_entity }
      end
    end
    add_audit_trail(:details => "Cloned a template with alias: #{@user_template.alias}")
  end
  

  # DELETE /user_templates/1
  # DELETE /user_templates/1.xml
  def destroy
    @user_template = UserTemplate.find(params[:id])
    @user_template.destroy

    respond_to do |format|
      format.html { redirect_to(user_templates_url) }
      format.xml  { head :ok }
    end
    add_audit_trail(:details => "Deleted a template with alias: #{@user_template.alias}")
  end

  private

  def set_html_edit
    if params[:html_edit]
      @html_edit = (params[:html_edit] == 'yes')
    else
      @html_edit = true
    end
  end
end
