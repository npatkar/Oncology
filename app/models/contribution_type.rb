class ContributionType < ActiveRecord::Base

  # Table Relationships
  has_and_belongs_to_many :contributions
  
  # Returns an array of contribution_types for specified contribution / user pair
  # There "should" be only one result
  def self.find_by_user_and_contribution(user_id, contribution_id)
    # Ensure we always get valid numbers for our query
    user_id = user_id.to_s.to_i
    contribution_id = contribution_id.to_s.to_i
    
    ctypes = ContributionType.find_by_sql(
      "SELECT contribution_types.*
       FROM contributions 
       INNER JOIN contribution_types_contributions ON contributions.id = contribution_types_contributions.contribution_id
       INNER JOIN contribution_types ON contribution_types.id = contribution_types_contributions.contribution_type_id
       WHERE contributions.user_id = #{user_id} AND contributions.id = #{contribution_id}" )
       
    return ctypes
  end

  def to_s
    self.title
  end
end
