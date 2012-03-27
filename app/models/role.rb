class Role < ActiveRecord::Base
  set_primary_key('role_id')

  has_many :role_instances
  has_many :users, :through => :role_instances

  # Lookup a role, and cache it for later use
  def self.lookup(key_or_role)
    # If we're already a role, then return ourselves
    if key_or_role.class == self then return key_or_role end
    case key_or_role.to_sym
      when 'all'
        Rails.cache.fetch('Role.all') { all }
      else
        Rails.cache.fetch("Role.#{key_or_role.to_s}") { self.find_by_key(key_or_role.to_s) }
    end
  end

  # Given an array of roles or role keys, return an array of all the equivalent roles
  def self.expand_roles(keys_or_roles)
    keys_or_roles.collect {|key| equiv_roles(key)}.flatten
  end

  # Return an array of roles that a given role has permissions for.. 
  # For example, super_admin role has all permissions of admin and user, so return those in an array
  # This is intended to be used to figure out when a permission is allowed, by performing an array
  #  intersection between the roles a user has, and this returned array of equivalent roles which are
  #  required for permission to do some action
  def self.equiv_roles(key_or_role)
    case key_or_role.to_sym
      when 'all'
        lookup(:all)
      when 'corr_author'
        [lookup(:corr_author), lookup(:author)]
      when 'co_author'
        [lookup(:co_author), lookup(:author)]
      when 'author'
        [lookup(:author)]
       when 'senior_editor'
        [lookup(:senior_editor),lookup(:editor)]
      when 'editor'
        [lookup(:editor)]
      when 'board_member'
        [lookup(:board_member)]
      when 'assistant'
        [lookup(:assistant)]
      when 'user'
        [lookup(:user)]
      when 'admin'
        [lookup(:admin), lookup(:user)]
      when 'super_admin'
        [lookup(:super_admin), lookup(:admin), lookup(:user)]
      when 'medical_writer'
        [lookup(:medical_writer)]
      when 'reviewer'
        [lookup(:reviewer)]
      
    end
  end

  # Return true if the given role is included in the given array of roles 
  def self.has_role?(roles, role)
  print role
    role = lookup(role)
    roles.each do |r|
       if r.key == role.key then 
       		return true 
       end
    end 
    return false
  end

  # Return true if the given role is included in the given array of roles (after expansion)
  def self.has_expanded_role?(roles, role)
    self.has_role?(self.expand_roles(roles), role)
  end

  def == (role2)
    self.key == role2.key 
  end

  # Define the to_sym method, so we return the Role key as a symbol (used by equiv_roles)
  def to_sym
    self.key.to_sym
  end

  def id
    self.role_id
  end
end
