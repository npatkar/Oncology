class ChargeTypesController < ApplicationController
  # GET /charge_types
  # GET /charge_types.xml
 
  before_filter :must_be_admin

  def index
    @charge_types = ChargeType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @charge_types }
    end
  end

  # GET /charge_types/1
  # GET /charge_types/1.xml
  def show
    @charge_type = ChargeType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @charge_type }
    end
  end

  # GET /charge_types/new
  # GET /charge_types/new.xml
  def new
    @charge_type = ChargeType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @charge_type }
    end
  end

  # GET /charge_types/1/edit
  def edit
    @charge_type = ChargeType.find(params[:id])
  end

  # POST /charge_types
  # POST /charge_types.xml
  def create
    @charge_type = ChargeType.new(params[:charge_type])

    respond_to do |format|
      if @charge_type.save
        flash[:notice] = 'ChargeType was successfully created.'
        format.html { redirect_to(@charge_type) }
        format.xml  { render :xml => @charge_type, :status => :created, :location => @charge_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @charge_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /charge_types/1
  # PUT /charge_types/1.xml
  def update
    @charge_type = ChargeType.find(params[:id])

    respond_to do |format|
      if @charge_type.update_attributes(params[:charge_type])
        flash[:notice] = 'ChargeType was successfully updated.'
        format.html { redirect_to(@charge_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @charge_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /charge_types/1
  # DELETE /charge_types/1.xml
  def destroy
    @charge_type = ChargeType.find(params[:id])
    @charge_type.destroy

    respond_to do |format|
      format.html { redirect_to(charge_types_url) }
      format.xml  { head :ok }
    end
  end
end
