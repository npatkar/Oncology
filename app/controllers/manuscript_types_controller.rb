class ManuscriptTypesController < ApplicationController
  # GET /manuscript_types
  # GET /manuscript_types.xml
   before_filter :must_be_admin, :except => [:links]

  def index
    @manuscript_types = ManuscriptType.find(:all,:order => "order_num")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manuscript_types }
    end
  end


  # GET /manuscript_types/new
  # GET /manuscript_types/new.xml
  def new
    #@manuscript_type = ManuscriptType.new
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @manuscript_type }
    end
  end

  # GET /manuscript_types/1/edit
  def edit
    @manuscript_type = ManuscriptType.find(params[:id])
      respond_to do |format|
      format.html # new.html.erb
      format.js
     end
  end

  # POST /manuscript_types
  # POST /manuscript_types.xml
  def create
    @manuscript_type = ManuscriptType.new(params[:manuscript_type])

    respond_to do |format|
      if @manuscript_type.save
        flash[:notice] = 'ManuscriptType was successfully created.'
        format.html { redirect_to manuscript_types_url }
        format.xml  { render :xml => @manuscript_type, :status => :created, :location => @manuscript_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @manuscript_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manuscript_types/1
  # PUT /manuscript_types/1.xml
  def update
    @manuscript_type = ManuscriptType.find(params[:id])

    respond_to do |format|
      if @manuscript_type.update_attributes(params[:manuscript_type])
        flash[:notice] = 'ManuscriptType was successfully updated.'
        format.html { redirect_to manuscript_types_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manuscript_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manuscript_types/1
  # DELETE /manuscript_types/1.xml
  def destroy
    @manuscript_type = ManuscriptType.find(params[:id])
    @manuscript_type.destroy

    respond_to do |format|
      format.html { redirect_to(manuscript_types_url) }
      format.xml  { head :ok }
    end
  end
  
  def links
    @manuscript_types = ManuscriptType.find(:all,:conditions=>{:enabled=>true},:order => "order_num")

    respond_to do |format|
      format.html # index.html.erb
      format.js {render :partial=>'type_links'}
    end
  end
  
  
end
