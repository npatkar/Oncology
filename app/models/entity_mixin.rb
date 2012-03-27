module EntityMixin
  
  def self.included(base)
    base.instance_eval("has_many :entity_statuses,:as=>:trackable,:dependent=>:delete_all,:order => 'created_at ASC'")
  end
  
 def change_status(key)  
   key = key.to_s  
   return false if has_current_status_of?(key)
   status = Status.find_by_key(key)
   if (status)
       entity_status = EntityStatus.new
       entity_status.status = status
       self.entity_statuses << entity_status
       logger.info("//////////// Changing the status of: #{self.class.name}, ID: #{self.id}, to status: #{key} /////////////////")
       return true
    else
      raise "No Status was found with key => #{key}"
   end
 end
 
 # Addes a status, withtout setting it to the current status. Accepts a 2nd argument which is to be forced as the 'created_at' date
 # This is so we can fix problem statuses that were never created, but should have been. Invite links for example (AMA - 12 Nov 2010) 
 def add_status(key, created_at = nil)
   created_at ||= Time.now
   key = key.to_s  
   status = Status.find_by_key(key)
   if (status)
       entity_status = EntityStatus.new
       entity_status.status = status
       self.entity_statuses << entity_status
       entity_status.update_attribute(:created_at, created_at)
       logger.info("//////////// Adding the status of: #{self.class.name}, ID: #{self.id}, to status: #{key} /////////////////")
       return true
    else
      raise "No Status was found with key => #{key}"
   end
 end

 def current_status
    es = EntityStatus.find(:last, :conditions => {:trackable_id => self.id, :trackable_type => self.class.to_s})
    status = es.status if es
   return status ? status : nil
 end
 
 def has_current_status_of?(key)
   key = key.to_s
   return current_status_key == key
 end

 def current_status_name(attribute = false)
   attribute ||= 'name'
   status = current_status
   return status ? status.send(attribute.to_s) : "No Status Yet"
 end
 
 def current_status_key
   status = current_status
   return status ? status.key : ""
 end

 def days_in_current_status
   if self.current_entity_status.created_at
     ((Time.now - self.current_entity_status.created_at)/86400).to_i
   else
     0
   end
 end
 
 def current_status_date
    status = current_entity_status
    unless(status.nil?)
      #return status.created_at.strftime("%m/%d/%Y at %I:%M%p") 
      return status.created_at.strftime("%m/%d/%y") 
    else
      return "No Date Set"
    end
 end
 
 def current_status_time
    status = current_entity_status
    unless(status.nil?)
      #return status.created_at.strftime("%m/%d/%Y at %I:%M%p") 
      return status.created_at
    else
      return nil
    end 
 end
 
 def current_entity_status
     EntityStatus.find(:last, :conditions =>{:trackable_id=>self.id,:trackable_type=>self.class.to_s})  
 end
 
 def has_had_status?(key)   
   had_it = false
   key = key.to_s
   status = Status.find_by_key(key)
   self.entity_statuses.each do |es|
       return true if es.status_id == status.id
   end  
   return had_it
 end

 # Returns the DateTime of the given status
 # If the entity status is not found, return nil 
 # (Formerly returning "" when not found, but changed so our method wouldn't return 2 different data types - AMA 12 Nov 2010)
 def time_of_status(key)
     key = key.to_s
     status = Status.find_by_key(key)
     if status
       es = EntityStatus.find(:last, :conditions => {:trackable_id => self.id, :status_id => status.id}, :order => :created_at) 
       return es ? es.created_at : nil
     else
        raise "No Status was found with key => #{key}"
     end
 end

 # Returns an Array of the DateTime(S) of the given status
 # If entity statuses of given key are not found, return an empty array 
 def times_of_status(key)
     key = key.to_s
     status = Status.find_by_key(key)
     if status
       ess = EntityStatus.find(:all, :conditions => {:trackable_id => self.id, :status_id => status.id}, :order => :created_at) 
       return ess.collect{|es| es.created_at}.sort
     else
        raise "No Status was found with key => #{key}"
     end
 end


 def has_had_any_status?(statuses)   
   statuses.each do |key|   
     had_status = self.has_had_status?(key)
     return true if had_status
   end
    
    return false
 end
 
def clear_statuses!
  self.entity_statuses.clear  
end

def self.hello
  p "hellow"
end



def get_all_statuses
   statuses = Array.new
    self.entity_statuses.each do|es|
       statuses << "#{es.status.name}(#{es.created_at.strftime('%m/%d/%y')})" if es.status
   end
 return statuses
end

     
end
