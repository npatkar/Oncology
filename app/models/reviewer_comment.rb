class ReviewerComment < ActiveRecord::Base
  belongs_to :article_submission_reviewer
  has_many :reviewer_comment_revisions,:order =>"created_at"
  include EntityMixin
  SUBMITTED = "reviewer_comments_submitted"
  SAVED = "reviewer_comments_saved"
  
 def get_rating(attr)
     val = self[attr].to_s
     case val     
     when 'A'
       return "Outstanding"
     when 'B'
       return "Good"
     when 'C'
       return "Fair"
     when 'D'
       return "Substandard"
     when 'true'
       return "Yes"
     when 'false'
       return "No"
     else
       return "N/A"
     end
 end
 
 
 def latest_revision(type)
    type = type.to_s
    @last = ReviewerCommentRevision.find(:last,:conditions=>[ "reviewer_comment_id= ? and #{type.to_s} is not null", self.id])
    return @last ? @last.send(type) : ""
 end
 
 def latest_revision_create_date(type)
     @last = ReviewerCommentRevision.find(:last,:conditions=>[ "reviewer_comment_id= ? and #{type.to_s} is not null", self.id])
       return @last ? @last.created_at : ""

 end
 
 
  def isSubmitted?
    self.has_current_status_of?(SUBMITTED) 
  end
  
  def submit!
    self.change_status(SUBMITTED) 
  end
  
  def mark_saved!
     self.change_status(SAVED)
  end
end
