class ReviewerCommentsRevisionsController < ApplicationController
  
before_filter :must_be_admin
  

def create_revision
  @original = ReviewerComment.find(params[:id])
  @revision =  ReviewerCommentRevision.create(params[:reviewer_comment_revision])
  @original.reviewer_comment_revision = @revision
  respond_to do |format|
    format.html
    format.js   
  end 
end

end