class ConfigurationController < ApplicationController
  
  
before_filter :must_be_admin





def index 
  @configurations = Configuation.find(:all)
   
end
  




end