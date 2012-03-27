module EmailableMixin
  
  ############################# CLASS METHODS ##########################
  
  def self.included(base)
    base.instance_eval("has_many :email_logs, :as => :email_loggable, :dependent=>:delete_all, :order => 'created_at ASC'")
  end
  
  
  ############################## INSTANCE METHODS ######################
 
  # Returns the date the last email of a specified category was sent 
   def email_sent_at(category)
    emails = self.email_logs.select {|e| e.category == category}
    emails.collect {|e| e.created_at}.sort.last
  end
  
    # Returns an array of the dates the email of a specified category was sent 
   def emails_sent_at(category)
    emails = self.email_logs.select {|e|e.category == category}
    emails.collect {|e| e.created_at}.sort
  end

  # Returns all emails or all emails of a specified category (if given)
  def emails(category = nil)
     return category ? self.email_logs.select {|e| e.category == category} : self.email_logs
  end
  
end