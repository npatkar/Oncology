class EntityStatus < ActiveRecord::Base
  
   belongs_to :trackable, :polymorphic => true
   belongs_to :status
   
   
   
   def self.find_latest(id,class_name)
     return self.find(:first, :conditions => {:trackable_id => id,:trackable_type => class_name},:order => "created_at DESC")
   end

end
