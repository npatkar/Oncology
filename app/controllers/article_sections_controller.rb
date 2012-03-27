class ArticleSectionsController < ApplicationController
  
  before_filter :must_be_admin
  
  # GET /article_sections
  # GET /article_sections.xml
  def index
    @article_sections = ArticleSection.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @article_sections }
    end
  end

  # GET /article_sections/1
  # GET /article_sections/1.xml
  def show
    @article_section = ArticleSection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article_section }
    end
  end

  # GET /article_sections/new
  # GET /article_sections/new.xml
  def new
    @article_section = ArticleSection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article_section }
    end
  end

  # GET /article_sections/1/edit
  def edit
    @article_section = ArticleSection.find(params[:id])
  end

  # POST /article_sections
  # POST /article_sections.xml
  def create
    @article_section = ArticleSection.new(params[:article_section])

    respond_to do |format|
      if @article_section.save
        flash[:notice] = 'ArticleSection was successfully created.'
        format.html { redirect_to(@article_section) }
        format.xml  { render :xml => @article_section, :status => :created, :location => @article_section }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /article_sections/1
  # PUT /article_sections/1.xml
  def update
    @article_section = ArticleSection.find(params[:id])

    respond_to do |format|
      if @article_section.update_attributes(params[:article_section])
        flash[:notice] = 'ArticleSection was successfully updated.'
        format.html { redirect_to(@article_section) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /article_sections/1
  # DELETE /article_sections/1.xml
  def destroy
    @article_section = ArticleSection.find(params[:id])
    @article_section.destroy

    respond_to do |format|
      format.html { redirect_to(article_sections_url) }
      format.xml  { head :ok }
    end
  end
end
