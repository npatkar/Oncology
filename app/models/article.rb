class Article < ActiveRecord::Base

  set_primary_key("article_id")


  ########################## Associations #############################

  has_many :role_instances, :dependent => :destroy
  has_many :users, :through => :role_instances
  has_many :article_submissions
  has_and_belongs_to_many :article_sections, 
                          :join_table => 'article_to_articlesection', 
                          :foreign_key => 'article_id',
                          :association_foreign_key => 'section_id'
  belongs_to :article_status


  include EntityMixin   


  ######################### INSTANCE METHODS ##########################  

  def first_article_section_id
    self.article_sections ? self.article_sections.first.id : nil
  end 

end
