class UserTemplate < ActiveRecord::Base
  
  # Table attributes

  # Table Relationships
  
  # Validations
  validates_presence_of :title
  validates_uniqueness_of :title

  
  # Triggers
  before_save :parse_text

  
  # finds a template and merges a variable into the template
  # if we were passed nil or didn't receive a var, then we just return the template (html or none, depeding on the template)
  #  and we cache the template text only in this case
  # if we were passed a variable, then we find the template
  def self.get_template(template_alias, template_var = nil)
    #logger.info("**** get_template(#{template_alias}, #{template_var})")
    p "***********#{template_var}"
    if template_var.nil?
      @@template_cache ||= {}
      if @@template_cache.has_key?(template_alias)
        #logger.info("***** UserTemplate cache HIT: #{template_alias}")
        return @@template_cache[template_alias]
      else
        #logger.info("***** UserTemplate cache MISS: #{template_alias}")
      end
      begin
        t = self.find_by_alias(template_alias)
        p "((((((((#{template_var}((((((((((((((((("
        if t     
          return @@template_cache[template_alias] = t.template_text
        else
          p "(((222222222(((((((((("
          return @@template_cache[template_alias] = self.default_value(template_alias)
        end
      catch
        return @@template_cache[template_alias] = self.default_value(template_alias)
      end
     
    else
      #logger.info("***** UserTemplate can't use cache for: #{template_alias}, merging var: #{template_var}")
      if template_var.kind_of?(Array)
        self.merge_vars(self.get_template(template_alias, nil), template_var)
      else
       
          self.merge_var(self.get_template(template_alias, nil), template_var)
      end
    end
    

  end
 
  def self.default_value(template_alias = nil)
    case template_alias
    when /^yes_/
      'Yes'
    when /^no_/
      'No'
    else
      ''
    end
  end
 
  # clear the template cache, useful if we edit templates
  def self.clear_template_cache(template_alias = nil)
    @@template_cache ||= {}
    if template_alias.nil?
      @@template_cache = {} 
    else
      @@template_cache.delete(template_alias)
    end
  end

  # merge text with an object and it's method calls that are embedded in the text
  # Find all the method calls = '[[xxxxx.]xxxx]', and substitute the value of calling the given object with the method call
  # if no '.' is found in the method call, then the main_object is the calling object
  # if a '.' is found, then first the method before the '.' is called, then the method after the '.' is called on the result of the previous call (chaining methods)
  #
  # Note: I'll bet an inline execution would work here, but would it be a lot slower?
  def self.merge_var(text_orig, template_var = nil)
    text = text_orig.clone
    unless template_var.nil?
      result = true 
      while result do      
        result = text.gsub!(/   \[    ( ([^.\]]+) \.)?    ([^.\]]+)     \]   /x) do |match| 
          #logger.info("-- gsub $0:#{$0}-$1:#{$1}-$2:#{$2}-$3:#{$3}-")
          obj_name = $2 
          method_name = $3 
          obj = if self.respond_to?(method_name) 
             self.send(method_name)
          elsif obj_name.nil? 
            template_var 
          else
            # If we actually have a method named this, then return the object returned by the method
            # else... return the matched string
            template_var.respond_to?(obj_name) ? template_var.send(obj_name) : $&
          end
          #logger.info("---> obj_name:#{obj_name} method_name:#{method_name} text: #{obj.send(method_name)}") 
          obj.respond_to?(method_name) ? resolve_to_str(obj.send(method_name)) : obj
        end # do match

      end # while result 
    end # unless template_var.nil?

    text
  end
   
   def self.merge_vars(text_orig, template_vars = nil)
      text = text_orig.clone    
      p "(((((((((((((((((((((((((("
      unless template_vars.nil?
        result = true 
        strings = Array.new
            while (result) do    
                result = text.gsub!(/   \[    ( ([^.\]]+) \.)?    ([^.\]]+)     \]   /x) do |match| 
                  obj_name = $2 
                  method_name = $3 
                  p obj_name
                  p method_name
                  val = "#{obj_name}.#{method_name}"   
                  template_vars.each do|template_var|                 
                      obj = obj_name.nil? ? template_var : get_child_obj(template_vars,obj_name,$&)
                       if self.respond_to?(method_name) 
                         val = self.send(method_name)
                       elsif obj.respond_to?(method_name) 
                        
                          val = resolve_to_str(obj.send(method_name))     
                          break
                      elsif obj.kind_of?(String) && method_name.match(/string_\d?/)
                           strings << obj unless strings.include?obj
                           index = strings.index(obj)
                           m = method_name.sub("string_","")
                           if(m == (index+1).to_s)
                             val = obj
                             break
                           end
                      end
                  end
                  val
                end # do match
            end # while result            
      end # unless template_var.nil?
      return text
  end
   
   
   def get_child_obj(template_vars,obj_name,default)   
       val = nil
        template_vars.each do|template_var|
            if(template_var.respond_to?(obj_name))
                val = template_var.send(obj_name)
                break
            end
         end 
        return  val || default 
   end
   
  # return our textilized 'body_html' field or 'html' field, depending on the 'to_html' field
  def template_text
    self.to_html ? self.body_html : self.body
  end

  def self.next_business_day
    date = Time.now
    logger.info(date)
    date += 1
    while (date.wday % 7 == 0) or (date.wday % 7 == 6) do
      date += 1
    end   
    date.strftime('%A, %m/%d/%Y')    
  end

  private
  
  def self.resolve_to_str(obj)
#    logger.info( "\n\n\n-- obj class: #{obj.class} str: #{obj}")
    return case obj.class 
  when Array
#       logger.inf(" \n\n-- resolve_to Array...\n")
        obj.collect { |o| o.to_s}.join(", ")
      else
        obj
    end
  end
  
  def parse_text
#    if self.to_html
#      text = parse_special(self.body)
#     # self.body_html = BlueCloth::new(text).to_html
#    else
#      self.body_html = nil
#    end
#    #TODO test this
     self.body_html = parse_special(self.body)
  end

  # just some shortcuts
  def parse_special(text_orig)
    text = text_orig.gsub(/back_to_top/, '<a href="#top">back to top</a>')
    text.gsub!(/\b(\w+)_anchor\(([^)]*)\)/) do |match|
      "<a href='##{$1}'>#{$2}</a>"
    end
    text.gsub!(/\b(\w+)_defanchor\(([^)]*)\)/) do |match|
      "<a href='/definitions##{$1}'>#{$2}</a>"
    end
    text.gsub!(/\b(\w+)_anchor\b/) do |match|
      "<a id='#{$1}'></a>"
    end
    text.gsub!(/The Oncologist/, '<strong><em>The Oncologist</em></strong>')
    text
  end
  
end
