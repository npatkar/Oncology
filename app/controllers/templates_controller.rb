class TemplatesController < ApplicationController
  
  before_filter :must_be_admin
  
  # GET /templates
  # GET /templates.xml
  def index
    @templates = Template.find(:all, :order=>'title')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @templates }
    end
    add_audit_trail(:details => 'Viewed templates listing')
  end

  # GET /templates/1
  # GET /templates/1.xml
  def show
    @template = Template.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @template }
    end
    add_audit_trail(:details => "Viewed a template with alias: #{@template.alias}")
  end

  # GET /templates/new
  # GET /templates/new.xml
  def new
    @template = Template.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @template }
    end
  end

  # GET /templates/1/edit
  def edit
    @template = Template.find(params[:id])
    add_audit_trail(:details => "Edited a template with alias: #{@template.alias}")
  end

  # POST /templates
  # POST /templates.xml
  def create
    @template = Template.new(params[:template])

    respond_to do |format|
      if @template.save
        flash[:notice] = 'Template was successfully created.'
        format.html { redirect_to(templates_url) }
        format.xml  { render :xml => @template, :status => :created, :location => @template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @template.errors, :status => :unprocessable_entity }
      end
    end
    add_audit_trail(:details => "Created a template with alias: #{@template.alias}")
  end

  # PUT /templates/1
  # PUT /templates/1.xml
  def update
    @template = Template.find(params[:id])

    respond_to do |format|
      if @template.update_attributes(params[:template])
        flash[:notice] = 'Template was successfully updated.'
        format.html { redirect_to(templates_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @template.errors, :status => :unprocessable_entity }
      end
    end
    add_audit_trail(:details => "Updated a template with alias: #{@template.alias}")
  end
  
  def clone_template
    @template = Template.find(params[:id]).clone
    @template.title += '_copy'

    respond_to do |format|
      if @template.update_attributes(params[:template])
        flash[:notice] = 'Template was successfully updated.'
        format.html { redirect_to(templates_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @template.errors, :status => :unprocessable_entity }
      end
    end
    add_audit_trail(:details => "Cloned a template with alias: #{@template.alias}")
  end
  

  # DELETE /templates/1
  # DELETE /templates/1.xml
  def destroy
    @template = Template.find(params[:id])
    @template.destroy

    respond_to do |format|
      format.html { redirect_to(templates_url) }
      format.xml  { head :ok }
    end
    add_audit_trail(:details => "Deleted a template with alias: #{@template.alias}")
  end
end
