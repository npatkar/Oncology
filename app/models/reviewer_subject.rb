class ReviewerSubject < ActiveRecord::Base
 belongs_to :user
 belongs_to :article_section
 #validates_uniqueness_of :article_section_id,:through=>:user_id
  
  
end