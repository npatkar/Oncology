class ReviewerCommentReport
  

 include ActionView::Helpers::UrlHelper
 include ActionController::UrlWriter
 include ActionView::Helpers::TagHelper
 
 def initialize(article_submission,reviewer=nil)
   @a_s = article_submission
   @a_s_r_reviewers = @a_s.article_submission_reviewers
   @reviewer = reviewer
 end
  
  
  def article_submission
    @a_s
  end
  
 
 def reviewer_comment
      comments = @reviewer.reviewer_comment
      av = ActionView::Base.new(Rails::Configuration.new.view_path)
      av.class_eval do 
          include ApplicationHelper
       end
      return av.render(:partial => "reports/reviewer_comment", :locals => {:comments => comments})
 end
  
  
 def reviewer_comments  
   html = ""
   @a_s_r_reviewers.each do |rev|   
      html << "<h2>#{rev.reviewer.full_name}s Review</h2>"
      comments = rev.reviewer_comment
      submitted = comments ? comments.isSubmitted? : false
      if comments && submitted
        av = ActionView::Base.new(Rails::Configuration.new.view_path)
        av.class_eval do 
           include ApplicationHelper
        end
        html <<  av.render(:partial => "reports/reviewer_comments", :locals => {:comments => comments})
      elsif comments && !submitted
        html << "<p>Reviewer Comments Not Yet Submitted"
      else       
        html << "<p> No Reviewer Comments Entered</p>"
       end
        html << "<hr/>"
       end
   
   return html
 end
  
  
  
  def summary_link
    base_url = App::Config::base_url.chop.sub(/https?:\/\//,"")
    ReviewerCommentReport.default_url_options[:host] = base_url
    return  link_to("Initial Report", :controller => 'reports',:action => 'article_submission_review',:id => @a_s.id)
  end
  
  
  def note_of_recused_section_editors
       @a_s.note_of_recused_editors || "None Entered"
  end
  
  def section_editor_correspondence    
    @a_s.section_editor_correspondence || "None Entered"
  end
   
  def reviewer_cois
    @a_s.reviewer_potential_coi_info
  end  

  def manuscript_file_link
    if @a_s.updated_manuscript
      base_url = App::Config::base_url.chop.sub(/http:\/\//,"")
      permission_path = App::Config::base_url.chop + @a_s.updated_manuscript.file.filename
      path = base_url + article_submission.updated_manuscript.file.url
      name =  @a_s.updated_manuscript.file.filename
  
      return "<br/><a href='#{path}'>#{name}</a>"
    else
      return "No Updated Manuscript Link Uploaded"
    end
  end
end
