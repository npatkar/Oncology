class ContributionTypesController < ApplicationController
  
  before_filter :must_be_admin
  
  # GET /contribution_types
  # GET /contribution_types.xml
  def index
    @contribution_types = ContributionType.find(:all, :order => 'display_order')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contribution_types }
    end
  end

  # GET /contribution_types/1
  # GET /contribution_types/1.xml
  def show
    @contribution_type = ContributionType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contribution_type }
    end
  end

  # GET /contribution_types/new
  # GET /contribution_types/new.xml
  def new
    @contribution_type = ContributionType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contribution_type }
    end
  end

  # GET /contribution_types/1/edit
  def edit
    @contribution_type = ContributionType.find(params[:id])
  end

  # POST /contribution_types
  # POST /contribution_types.xml
  def create
    @contribution_type = ContributionType.new(params[:contribution_type])

    respond_to do |format|
      if @contribution_type.save
        flash[:notice] = 'ContributionType was successfully created.'
        format.html { redirect_to(@contribution_type) }
        format.xml  { render :xml => @contribution_type, :status => :created, :location => @contribution_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contribution_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contribution_types/1
  # PUT /contribution_types/1.xml
  def update
    @contribution_type = ContributionType.find(params[:id])

    respond_to do |format|
      if @contribution_type.update_attributes(params[:contribution_type])
        flash[:notice] = 'ContributionType was successfully updated.'
        format.html { redirect_to(@contribution_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contribution_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contribution_types/1
  # DELETE /contribution_types/1.xml
  def destroy
    @contribution_type = ContributionType.find(params[:id])
    @contribution_type.destroy

    respond_to do |format|
      format.html { redirect_to(contribution_types_url) }
      format.xml  { head :ok }
    end
  end
end
