class Entity<ActiveRecord::Base

has_many :statuses, :order => 'name ASC'
    
end