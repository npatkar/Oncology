class RoleInstance < ActiveRecord::Base

  set_table_name("user_to_role")
  set_primary_key("user_to_role_id")

  belongs_to :user
  belongs_to :role

  belongs_to :article
end
