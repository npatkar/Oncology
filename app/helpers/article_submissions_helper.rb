module ArticleSubmissionsHelper
  
  def manuscript_type_boxes(article_submission)
    html = "" 
    types = ManuscriptType.find(:all, :conditions => {:enabled => true})
    types.each do|type|
      html << radio_button(:article_submission, :manuscript_type_id, type.id)
      html << label_tag("manuscript_type_id_#{type.id}", type.name)
      html << "<br/>"
    end
 
    return html
  end 


end
