class ArticleSection < ActiveRecord::Base
  
  # Table properties
  set_primary_key("article_section_id")
  
  # Table Relationships
  belongs_to :active_status
  has_and_belongs_to_many :articles, :join_table => 'article_to_articlesection'#, :foreign_key => 'article_id'
  has_many :reviewer_subjects,:dependent=>:destroy
  has_many :users,:through=>:reviewer_subjects

  # Modifiers
  acts_as_tree :order => 'display_order'
  
  def display_name
    if self.parent
      self.parent.article_section_name + ': ' + self.article_section_name
    else
      self.article_section_name
    end
  end
  
  def reviewers
     revs = Array.new
     self.users.each do|u|    
       revs << u if u.has_role?("reviewer")
     end
    
  end
  
end
