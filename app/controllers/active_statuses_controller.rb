class ActiveStatusesController < ApplicationController
  
  before_filter :must_be_admin
  
  # GET /active_statuses
  def index
    @active_statuses = ActiveStatus.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @active_statuses }
    end
  end

  # GET /active_statuses/1
  # GET /active_statuses/1.xml
  def show
    @active_status = ActiveStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @active_status }
    end
  end

  # GET /active_statuses/new
  # GET /active_statuses/new.xml
  def new
    @active_status = ActiveStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @active_status }
    end
  end

  # GET /active_statuses/1/edit
  def edit
    @active_status = ActiveStatus.find(params[:id])
  end

  # POST /active_statuses
  # POST /active_statuses.xml
  def create
    @active_status = ActiveStatus.new(params[:active_status])

    respond_to do |format|
      if @active_status.save
        flash[:notice] = 'ActiveStatus was successfully created.'
        format.html { redirect_to(@active_status) }
        format.xml  { render :xml => @active_status, :status => :created, :location => @active_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @active_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /active_statuses/1
  # PUT /active_statuses/1.xml
  def update
    @active_status = ActiveStatus.find(params[:id])

    respond_to do |format|
      if @active_status.update_attributes(params[:active_status])
        flash[:notice] = 'ActiveStatus was successfully updated.'
        format.html { redirect_to(@active_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @active_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /active_statuses/1
  # DELETE /active_statuses/1.xml
  def destroy
    @active_status = ActiveStatus.find(params[:id])
    @active_status.destroy

    respond_to do |format|
      format.html { redirect_to(active_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
