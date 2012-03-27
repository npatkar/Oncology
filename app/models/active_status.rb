class ActiveStatus < ActiveRecord::Base

  has_many :article_sections
  
  set_primary_key('active_status_id')

end
