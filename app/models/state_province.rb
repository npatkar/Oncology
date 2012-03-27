class StateProvince < ActiveRecord::Base
  
  # Table Description
  set_table_name "states_provinces"
  set_primary_key "state_province_id"

  # Table Relationships
  has_many :users
  
end
