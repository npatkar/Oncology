class ArticleSectionToHtm < ActiveRecord::Migration
  def self.up
  	    ActiveRecord::Base.transaction do
    		execute "alter table article_to_articlesection add column tmp_article_to_sections_id int(11)"
			execute "update article_to_articlesection set tmp_article_to_sections_id=article_to_sections_id"
			execute "alter table article_to_articlesection drop column article_to_sections_id"
			execute "alter table article_to_articlesection change tmp_article_to_sections_id article_to_sections_id int(11)"
    	end
  end

  def self.down
  	ActiveRecord::Base.transaction do
    	execute "alter table article_to_articlesection modify column article_to_sections_id int(11) AUTO_INCREMENT PRIMARY KEY "
    end
  end
end
