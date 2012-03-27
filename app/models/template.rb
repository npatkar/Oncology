class Template < ActiveRecord::Base
  
  # Table attributes

  # Table Relationships
  
  # Validations
  validates_presence_of :title
  validates_uniqueness_of :title

  
  # Triggers

  # Find all the method calls = '[xxxxx[.xxxx]]', and substitute the value of calling the given object with the method call
  # if no '.' is found in the method call, then the main_object is the calling object
  # if a '.' is found, then first the method before the '.' is called, then the method after the '.' is called on the result of the previous call (chaining methods)
  def var_merge(main_object)
    body = self.body
    result = true 
     while result do 
       #              regex =            object        method
       result = body.gsub!(/   \[    ( ([^.]+) \.)?    ([^.\]]+)     \]   /x) do |match| 
          obj_name = $2 
          method_name = $3 
          obj = obj_name.nil? ? main_object : main_object.send(obj_name) 
#          logger.info("---> obj_name:#{obj_name} method_name:#{method_name} text: #{obj.send(method_name)}") 
          obj.send(method_name) 
       end 
    end
    body
  end
  
end
