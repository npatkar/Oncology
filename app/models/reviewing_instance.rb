class ReviewingInstance < ActiveRecord::Base
  
  # Table Relationships
  belongs_to :user
  belongs_to :article_submission
  
  # Validations
  validates_presence_of :article_submission_id
  validates_presence_of :user_id
  
end
