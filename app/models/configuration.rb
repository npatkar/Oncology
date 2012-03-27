class Configuration<ActiveRecord::Base
  
  
def self.get_value(name)
  name = name.to_s
  return self.find_by_name(name).value
  
end

def self.advance_manuscript_sequence
  @configuration = Configuration.find_by_name("manuscript_sequence")
  if(@configuration.nil?)
    @configuration = Configuration.new({:name=>"manuscript_sequence"}) 
  end
 val = @configuration.value

  #T10-123 put in article table under manuscript_num
  curr_year= Time.now.strftime("%y")
  if(val!=0 && val && val.match(/T\d{2}-\d?/))
    toks = val.split("-")
    tok_1 = toks[0]
    tok_2 = toks[1]
    seq =  "T#{curr_year}" == tok_1 ?  tok_2.to_i + 1 : 0  
    new_seq = "T#{curr_year}-#{seq}"
    else
    new_seq = "T#{curr_year}-1"
  end
  
   @configuration.value = new_seq

   return @configuration.save
end
  
   
end