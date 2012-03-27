class AuditTrail < ActiveRecord::Base
  belongs_to :user

  belongs_to :user_acted_as,
             :class_name => 'User'

  belongs_to :user_acted_on,
             :class_name => 'User'

  belongs_to :article_submission

  belongs_to :contribution

  belongs_to :coi_form


  validates_presence_of :details
  validates_presence_of :user_id

end
