require 'fastercsv'
class ReportsController < ApplicationController

  layout 'admin'

  before_filter :must_be_admin
  before_filter :check_filter_params


  def gateway
    joins = []
    @sort_by = 'id'    # default
    if  CcTransaction.columns.collect {|c| c.name}.include?(params[:sort_by])
      @sort_by = params[:sort_by]
    end

    conditions = ['1']
    if @date_range > 0
      add_conditions(conditions, 'charges.created_at > (DATE_SUB(NOW(), INTERVAL "?" DAY))', @date_range)
      joins << :charge
    end
      
    @cc_transactions = CcTransaction.paginate :conditions => conditions, :joins => joins, :page => params[:page], :per_page => @per_page, :order => "cc_transactions.#{@sort_by} #{@direction}" 
    add_audit_trail(:details => 'Checked the gateway report')
  end


  # only shows settled charges
  def charge
    get_charges
    add_audit_trail(:details => 'Checked the charges report')
  end

  def charge_export
    get_charges
    labels = ['Processed', 'User', 'Amount'] 
    rows = []
    @charges.each do |c|
      rows << [c.processed.strftime("%x %H:%M"), c.article_submission.corresponding_author.full_name, c.amount / 100] 
    end
    send_csv(:labels => labels, :rows => rows, :filename => 'Charges.csv')
    add_audit_trail(:details => 'Exported the charges report')
  end
  
  def manuscripts_status
    @article_submissions = ArticleSubmission.find_all_by_status(:statuses_to_drop => ['article_submission_admin_removed', 'article_submission_removed'])
  end
  
  def manuscripts_status_csv
    @article_submissions = ArticleSubmission.find_all_by_status(:statuses_to_drop => ['article_submission_admin_removed', 'article_submission_removed'])
    
    labels = ['No', 'Submitted', 'Title', 'Status']
    rows = []

    @article_submissions.each do |as|
      rows << [as.article ? as.article.manuscript_num : 'Not Imported',
               as.first_submission.committed ? as.first_submission.committed.strftime("%m/%d/%y") : '',
               as.title,
               as.current_status_name]
    end
    send_csv(:labels => labels, :rows => rows, :filename => 'Manuscript Statuses.csv')
    add_audit_trail(:details => 'Exported the manuscripts status report')
  end

  # only shows rejected manuscripts
  def rejected_manuscripts
    get_rejected_manuscripts
    add_audit_trail(:details => 'Checked the rejected manuscripts report')
  end

  def rejected_manuscripts_export
    get_rejected_manuscripts
    labels = ['Date Received', 'Corresponding Author', 'Title'] 
    rows = []
    @articles.each do |key, group|
      rows << [ArticleSection.find(key).article_section_name]
      group.each do |a|
        ri = a.role_instances.find_by_role_id(1)
        ca_name = ri ? ri.user.name : 'No Corresponding Author'
        rows << [a.date_final_decision, ca_name, a.title]
      end
      rows << ['']
    end
    send_csv(:labels => labels, :rows => rows, :filename => 'Rejected manuscripts.csv')
    add_audit_trail(:details => 'Exported the rejected manuscripts report')
  end

  def article_submission
    @article = nil  # default
    if params.has_key?('id') && params[:id].to_i >= 0
      @article_submission = ArticleSubmission.find(params[:id].to_i)
      @article = @article_submission.article
    end
    @entity = Entity.find_by_entity_type("article_submission")
    if(@entity)
     @statuses = @entity.statuses
   end
     @curr_es = @article_submission.current_status
     @status = @curr_es.nil? ? Status.new : @curr_es
    add_audit_trail(:details => 'changed an article status')
  end

  def assign_article_status 
    @article = Article.find(params[:article_id])
    @status = Status.find(params[:status][:id]) 
   # @article.article_status = @status Just in case we need to go back to the old way
    @entity_status = EntityStatus.new
    @entity_status.status = @status
   
    msg =  @article.entity_statuses<<@entity_status ? "Article Status Updated" : "Article Status Update Failed"
    flash[:notice] = msg
    redirect_to :action=>:article_submission,:id=>@article.article_submission.id
  end
   
  def assign_article_submission_status 

    @article_submission = ArticleSubmission.find(params[:id])
    @status = Status.find(params[:status][:id]) 
    #@article.article_status = @status Just in case we need to go back to the old way 
    if(@status.key == "article_submission_forms_received")
        @article_submission.import_to_pf unless @article_submission.article
        msg = "Article Submission Imported to Pub Forcaster"
    elsif @status.key == ArticleSubmission::PROVISIONALLY_ACCEPTED
      @article_submission.change_status(ArticleSubmission::PROVISIONALLY_ACCEPTED)
      @article_submission.update_attribute(:resubmitted,true)
      rev = @article_submission.create_revision!
      msg = "Submission Provisionally Accepted. Revision #{rev.version} has been created"
    else
      msg =  @article_submission.change_status(@status.key) ? "Article Submission Status Updated" : "Article Submission Status Update Failed"  
    end
    
    if(@article_submission.article)
      article = @article_submission.article
      article_status = ArticleStatus.find_by_article_submission_status_key(@status.key)
      article.article_status = article_status
      article.save
    end  
    
    render :js =>"AjaxPopup.OpenBoxWithText($('article_status_form_#{@article_submission.id}'),true,\"#{msg}\",null)"
  end


  def article_submission_review
     @article_submission = ArticleSubmission.find(params[:id].to_i)
     @article_section = @article_submission.article_section
     @users = @article_section.users
     @reviewers = Array.new
     @section_editors = Array.new
     @board_members = Array.new
     @entity = Entity.find_by_entity_type("article_submission")
     @statuses = @entity.statuses
     @users.each do|user|
        if(user.has_role?:reviewer)
          @reviewers << user
        end      
        if(user.has_role?:editor)  
           @section_editors << user
       end
        if(user.has_role?:board_member)  
          @board_members << user
        end
     end
     @curr_es = @article_submission.current_status
     @status = @curr_es.nil? ? Status.new : @curr_es
     add_audit_trail(:details => 'Checked an article_submission review page')
  end
   

  def audit_trail
    get_audit_trails
    #add_audit_trail(:details => 'Checked audit trail report')
  end
  def audit_trail_export
    get_audit_trails
    labels = ['Time', 'User', 'Acted On', 'Article Submission', 'Details'] 
    rows = []
    @audit_trails.each do |a|
      rows << [a.created_at.strftime("%x %H:%M"), a.user.name, a.user_acted_on && a.user_acted_on.name, a.article_submission && a.article_submission.title, a.details] 
    end
    send_csv(:labels => labels, :rows => rows, :filename => 'Audit trail.csv')
    add_audit_trail(:details => 'Exported the audit trail report')
  end

  def users
    get_users
  end
  def users_export
    get_users
    labels = ['First name', 'Last name', 'Specialties', 'Email']
    rows = []
    @users.each do |u|
      rows << [u.first_name, u.last_name, u.article_sections.collect {|as| as.article_section_name}.join(","), u.email]
    end
    send_csv(:labels => labels, :rows => rows, :filename => 'Users.csv')
    add_audit_trail(:details => 'Exported the users') 
  end

  def users_of_accepted_articles
    get_users_of_accepted_articles
  end
  def users_of_accepted_articles_export
    get_users_of_accepted_articles
    labels = ['First name', 'Last name', 'Specialties', 'Email']
    rows = []
    @users.each do |u|
      rows << [u.first_name, u.last_name, u.article_sections.collect {|as| as.article_section_name}.join(","), u.email]
    end
    send_csv(:labels => labels, :rows => rows, :filename => 'Authors and coauthors of accepted articles.csv')
    add_audit_trail(:details => 'Exported the users of accepted articles') 
  end

  def show_audit_trail
    @audit_trail = AuditTrail.find(params[:id])
  end

  def manuscripts_in_review
    
  end
  
  def manuscripts_in_review_detailed

  end

  def manuscripts_in_review_csv
     labels = ["Started","ID","Manuscript Title","Date of Status","Time in Status"]
      submissions = ArticleSubmission.find_all_in_current_status("article_submission_in_review")
      submissions = submissions.group_by(&:special_status_by_reviewers)
      rows = Array.new
      submissions.each do |key, group|
       rows << [key,"","","",""]
         group.each do|sub|
           import_stat =  sub.article ? sub.article.manuscript_num : 'Not Imported'
           rows<<[sub.create_date.strftime("%m/%d/%y"),import_stat,sub.title,sub.status_date,sub.days_in_current_status]       
         end
      end
      send_csv(:labels => labels, :rows => rows, :filename => 'Manuscripts in review.csv')   
  end

  
  def manuscripts_in_review_csv
     labels = ["Started","ID","Manuscript Title","Date of Status","Time in Status"]
      submissions = ArticleSubmission.find_all_in_current_status("article_submission_in_review")
      submissions = submissions.group_by(&:special_status_by_reviewers)
      rows = Array.new
      submissions.each do |key, group|
       rows << [key,"","","",""]
         group.each do|sub|
           import_stat =  sub.article ? sub.article.manuscript_num : 'Not Imported'
           rows<<[sub.create_date.strftime("%m/%d/%y"),import_stat,sub.title,sub.status_date,sub.days_in_current_status]       
         end
      end
     
      send_csv(:labels => labels, :rows => rows, :filename => 'Manuscripts in review.csv')   
  end

  def submissions_with_user_country_csv
     labels = ["No",
               "Manuscript Title",
               "Corresponding Author",
               "Corresponding Author Country",
               "Coauthors",
               "Status",
               "Date of Status",
               "Time in Status"]
     entity = Entity.find_by_entity_type("article_submission");
     filter_key = params[:key]

     @status_keys = filter_key.blank? ? entity.statuses.collect{|s|s.key} : [filter_key]
     rows = []
     @status_keys.each do |key| 
       curr_index = rows.length
       name = Status.find_by_key(key).name
       rows <<[name,"","","","",""]
       rows <<["","","","","",""]
       rows <<["","","","","",""]
       submissions = ArticleSubmission.find_all_in_current_status(key)
       i = 0
       submissions.each do|sub|
         import_stat =  sub.article ? sub.article.manuscript_num : 'Not Imported'
         country = sub.corresponding_author && sub.corresponding_author.country ? sub.corresponding_author.country.country_2_code : 'No Country Assigned'
         rows << [
                 import_stat,
                 sub.title,
                 sub.corresponding_author && sub.corresponding_author.name,
                 country,
                 sub.coauthors.collect{|c|c.name}.join(","),
                 name,
                 sub.status_date,
                 sub.days_in_current_status]
         i+=1
       end
       rows[curr_index][1] = "#{i} mansucript(s)"
     end
     send_csv(:labels => labels, :rows => rows, :filename => 'Submissions summary with Corr Author Country')
   end 

  def submissions_by_user_country_csv
    country = Country.find_by_country_2_code(params[:c])
    return unless country
 
    labels = [ 
               "Article ID",
               "Submission ID",
               "Started",
               "Last Modified",
               "No",
               "Manuscript Title",
               "Corresponding Author",
               "Status"]

     rows = [country.country_name]
     subs = []
     User.find(:all, :conditions => "country_id = #{country.id}").each do |user|
       submissions = user.article_submissions
       submissions.each do|sub|
         next if subs.include?(sub.id) 
         subs << sub.id
         import_stat =  sub.article ? sub.article.manuscript_num : 'Not Imported'
         rows << [
                 sub.article && sub.article.id,
                 sub.id,
                 sub.create_date && sub.create_date.strftime("%m/%d/%y"),
                 sub.mod_date && sub.mod_date.strftime("%m/%d/%y"),
                 import_stat,
                 sub.title,
                 sub.corresponding_author && sub.corresponding_author.name,
                 sub.current_status_name,
                 sub.article && sub.article.article_status && sub.article.article_status.status
                 ]

       end
     end
     send_csv(:labels => labels, :rows => rows, :filename => "Submissions of #{country.country_name} authors")
   end 
  

   def articles_by_user_country_csv
     country = Country.find_by_country_2_code(params[:c])
     return unless country

     labels = ["Article ID",
               "Submission ID",
               "Started",
               "Last Modified",
               "No",
               "Article Title",
               "Corresponding Author",
               "Status",
               "Final Decision"
              ]
     rows = [country.country_name]
     subs = []
     User.find(:all, :conditions => "country_id = #{country.id}").each do |user|
       user.articles.each do|sub|
         next if subs.include?(sub.id) 
         subs << sub.id
         ca_role = sub.role_instances.find_by_role_id(1)
         corr_author = ca_role.nil? ? nil : ca_role.user

         rows << [
               sub.id,
               sub.article_submission && sub.article_submission.id,  
               sub.create_date && sub.create_date.strftime("%m/%d/%y"),
               sub.mod_date && sub.mod_date.strftime("%m/%d/%y"),
               sub.manuscript_num,
               sub.title,
               corr_author ? corr_author.name : 'No Corr Author',
               sub.article_status && sub.article_status.status,
               sub.final_decision_type
               ]
       end
     end
     send_csv(:labels => labels, :rows => rows, :filename => "Articles of #{country.country_name} authors")
   end

   def articles_with_user_country_csv
     labels = ["Started",
               "No",
               "Article Title",
               "Corresponding Author",
               "Corresponding Author Country"
              ]
     rows = []
     i = 0
     Article.find(:all).each do|sub|
       ca_role = sub.role_instances.find_by_role_id(1)
       corr_author = ca_role.nil? ? nil : ca_role.user
       country = ! corr_author.nil? && corr_author.country ? corr_author.country.country_2_code : 'No Country Assigned'
       rows << [
               sub.create_date && sub.create_date.strftime("%m/%d/%y"),
               sub.manuscript_num,
               sub.title,
               corr_author ? corr_author.name : 'No Corr Author',
               country
               ]
       i+=1
     end
     send_csv(:labels => labels, :rows => rows, :filename => 'Article summary with Corr Author Country')
   end 



   def manuscripts_summary    
      if params[:csv]       
        redirect_to :action => "manuscripts_summary_csv", :key => params[:status][:key]
      end
      @statuses = Entity.find_by_entity_type("article_submission").statuses
      @keys =  params[:status] ? [params[:status][:key]] : @statuses.collect{|s|s.key}
     
      if params[:types]
        @types = params[:types].values
      end
  end

   def manuscripts_aging    
      if params[:csv]       
        redirect_to :action => "manuscripts_aging_csv", :key => params[:status][:key]
      end
      @statuses = Entity.find_by_entity_type("article_submission").statuses
      @keys =  params[:status] ? [params[:status][:key]] : @statuses.collect{|s|s.key}
     
      if params[:types]
        @types = params[:types].values
      end
  end

  def manuscripts_summary_csv  
         labels = ["Started","ID","Manuscript Title","Corresponding Author","Coauthors","Status","Date of Status","Time in Status"]
         entity = Entity.find_by_entity_type("article_submission");
         filter_key = params[:key]

         @status_keys = filter_key.blank? ? entity.statuses.collect{|s|s.key} : [filter_key]
         rows = []
         @status_keys.each do |key| 
           curr_index = rows.length
           name = Status.find_by_key(key).name
           rows <<[name,"","","","",""]
           rows <<["","","","","",""]
           rows <<["","","","","",""]
           submissions = ArticleSubmission.find_all_in_current_status(key)
           i = 0
           submissions.each do|sub|
             import_stat =  sub.article ? sub.article.manuscript_num : 'Not Imported'
             rows<<[sub.create_date.strftime("%m/%d/%y"),import_stat,sub.title,sub.corresponding_author && sub.corresponding_author.name,sub.coauthors.collect{|c|c.name}.join(","),name,sub.status_date,sub.days_in_current_status]
             i+=1
           end
           rows[curr_index][1] = "#{i} mansucript(s)"
       end
        send_csv(:labels => labels, :rows => rows, :filename => 'Manuscripts summary')
  end

  def manuscripts_aging_csv  
         labels = ["Started","ID","Manuscript Title","Corresponding Author","Coauthors","Status","Date of Status","Time in Status"]
         entity = Entity.find_by_entity_type("article_submission");
         filter_key = params[:key]

         @status_keys = filter_key.blank? ? entity.statuses.collect{|s|s.key} : [filter_key]
         rows = []
         @status_keys.each do |key| 
           curr_index = rows.length
           name = Status.find_by_key(key).name
           rows <<[name,"","","","",""]
           rows <<["","","","","",""]
           rows <<["","","","","",""]
           submissions = ArticleSubmission.find_all_in_current_status(key)
           i = 0
           submissions.each do|sub|
             import_stat =  sub.article ? sub.article.manuscript_num : 'Not Imported'
             rows<<[sub.create_date.strftime("%m/%d/%y"),import_stat,sub.title,sub.corresponding_author && sub.corresponding_author.name,sub.coauthors.collect{|c|c.name}.join(","),name,sub.status_date,sub.days_in_current_status]
             i+=1
           end
           rows[curr_index][1] = "#{i} mansucript(s)"
       end
        send_csv(:labels => labels, :rows => rows, :filename => 'Manuscripts Aging Report')
  end
  
  
  def reviewer_comment_report
    asrev = ArticleSubmissionReviewer.find(params[:id])
     @comment = ReviewerCommentReport.new(asrev.article,current_user)
  end
  
  def reviewer_comments_report
     @as = ArticleSubmission.find(params[:id])
     @siblings = @as.siblings
     @siblings = @siblings.sort_by{|s|s.id}
     @comments = Array.new
     @siblings.each do |s|
       @comments<< ReviewerCommentReport.new(s)
     end
     #@comments = ReviewerCommentReport.new(@as)
  end
  
  def send_reviewer_comments_report
     as = ArticleSubmission.find(params[:id])
     @comments = ReviewerCommentReport.new(as)
     message =""
     if  Notifier.deliver_reviewer_comments_report(@comments)
      message = "Your Email Has Been Successfully Sent"
    else
       message = "Email Sending Failed. Please Try Again."
     end
    render :js =>"AjaxPopup.OpenBoxWithText($('send_report_link'),true,\"#{message}\",null)"

  end


  def sales_report
    @months =get_sales_report_submissions 
  end


  def sales_report_csv
    labels = ["Manuscript Number","Manuscript Title","Pub Date","Manuscript Specialty"]
      rows = []
      @months =get_sales_report_submissions 
      @months.each do |month,value|
          unless value.empty?
             rows <<["","","","","",""]
             rows << [month]
             rows <<["","","","","",""]
             value.each do |sub|
              date = sub.article.publish_date.blank? ? "No Publish date" : sub.article.publish_date.strftime("%m/%d/%y")
              rows << [sub.article.manuscript_num,sub.title,date,sub.article_section.article_section_name]    
            end
          end
    end
    
     send_csv(:labels => labels, :rows => rows, :filename => 'Sales report.csv')
  end

  def outstanding_coi_report
    @submissions = ArticleSubmission.find(:all, :conditions => 'committed IS NOT NULL', :order => 'committed DESC')
  end
  
  def outstanding_reviewer_coi_report
    @reviewers = ArticleSubmissionReviewer.find(:all).select{|a|a.manuscript_coi_status.nil?}
  end
  
  def manuscript_coi_info
    @article_submission = ArticleSubmission.find(params[:id])
    @contributions =  @article_submission.contributions
    @reviewers = @article_submission.article_submission_reviewers
    @coi_holders = Array.new
    @coi_holders.concat(@contributions)
    @coi_holders.concat(@reviewers)
  end

  def article_submission_status_agreement
    @article_submissions = ArticleSubmission.find(:all)
    @article_submissions.delete_if do |as|
      if !as.article
        true # Remove all submissions without an associated article
      elsif !as.article.article_status
        false # Keep all submissions with articles that don't have valid statuses
      elsif as.current_status.name == as.article.article_status.status
        true # Remove all submissions whose statuses match their article's status
      else
        false # Don't remove the rest 
      end
    end
  end

  private
  
  def get_sales_report_submissions
    @submissions = ArticleSubmission.find_all_in_current_status(:article_submission_published)   
    months = {"No Publish Date"=>Array.new,"January"=>Array.new,"February"=>Array.new,"March"=>Array.new,"April"=>Array.new,"May"=>Array.new,
               "June"=>Array.new,"July"=>Array.new,"August"=>Array.new,"September"=>Array.new,"October"=>Array.new,
               "Novemeber"=>Array.new,"December"=>Array.new}            
    @submissions.each do|sub|   
        article = sub.article
        if article
           date = article.publish_date        
           month = date.blank? ? "No Publish Date" : date.strftime("%B")
           months[month] << sub    
        end 
    end
   
    months.each do |key,val| 
      val = val.group_by{|sub| sub.article_section.article_section_name} 
    end
    
    return months
  end
  def get_charges
    @sort_by = 'id'    # default
    if  Charge.columns.collect {|c| c.name}.include?(params[:sort_by])
      @sort_by = params[:sort_by]
    end

    conditions = ['1']
    if @date_range > 0
      add_conditions(conditions, 'charges.created_at > (DATE_SUB(NOW(), INTERVAL "?" DAY))', @date_range)
    end

    add_conditions(conditions, 'charges.state = "settled"')
  
    @charges = Charge.paginate :conditions => conditions, :page => params[:page], :per_page => @per_page, :order => "charges.#{@sort_by} #{@direction}" 
  end

  def get_rejected_manuscripts
    @sort_by = 'article_id'    # default
    if  Article.columns.collect {|c| c.name}.include?(params[:sort_by])
      @sort_by = params[:sort_by]
    end

    conditions = ['1']
    if @date_range > 0
      add_conditions(conditions, 'articles.date_final_decision > (DATE_SUB(NOW(), INTERVAL "?" DAY))', @date_range)
    end

    add_conditions(conditions, 'articles.final_decision_type = "Reject"')

    @articles = Article.find(:all, :conditions => conditions, :order => "articles.#{@sort_by} #{@direction}")
    @articles = @articles.group_by(&:first_article_section_id)
  end

  def get_audit_trails
    @sort_by = 'created_at'    # default
    if  AuditTrail.columns.collect {|c| c.name}.include?(params[:sort_by])
      @sort_by = params[:sort_by]
    end

    conditions = ['1']
    if @date_range > 0
      add_conditions(conditions, 'audit_trails.created_at > (DATE_SUB(NOW(), INTERVAL "?" DAY))', @date_range)
    end

    @audit_trails = AuditTrail.paginate :conditions => conditions, :page => params[:page], :per_page => @per_page, :order => "audit_trails.#{@sort_by} #{@direction}" 
  end

  def get_users
    @users = User.find(:all)
  end
  
  def get_users_of_accepted_articles
    @users = Article.find(:all, :conditions => {:final_decision_type => 'Accept'}).collect{|a| a.users}.flatten
  end

  def check_filter_params
    @search = nil  # default
    if params.has_key?(:search)
      @search = params[:search]
    end

    @direction = 'DESC'   # default
    if params.has_key?('direction') && params['direction'] == 'ASC'
      @direction = 'ASC'
    end

    @per_page = 25    # default
    if params.has_key?('per_page') && params[:per_page].to_i > 0
      @per_page = params[:per_page].to_i
    end

    @date_range = 0   # default
    if params.has_key?('date_range') && params[:date_range].to_i >= 0
      @date_range = params[:date_range].to_i
    end
  end
  

 
  def send_csv(result_set)
    # Set defaults
    result_set[:filename] ||= 'report.csv'

    csv_string = FasterCSV.generate do |csv|
      csv << result_set[:labels]
      result_set[:rows].each {|r| csv << r}
    end
    send_data(csv_string, :type => 'text/csv; charset=utf-8, header=present', :filename => result_set[:filename])
  end

end
