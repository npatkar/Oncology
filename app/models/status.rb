class Status < ActiveRecord::Base

  belongs_to :entity
  has_many :entity_statuses
  
end
