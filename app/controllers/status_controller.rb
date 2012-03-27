class StatusController < ApplicationController
  
  
  
def index


end
  

def assign_status  
  @trackable_obj = find_trackable
  @entity_status = EntityStatus.new
  @entity_status.status = Status.find(params[:status][:id])
  @trackable_obj.entity_statuses<<@entity_status
 
end

private
def find_trackable
  params.each do |name, value|
    if name =~ /(.+)_id$/
      return $1.classify.constantize.find(value)
    end
  end
  nil
end
  
end
