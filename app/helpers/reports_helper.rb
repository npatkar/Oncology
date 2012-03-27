module ReportsHelper
  
def color_background as
  days = as.days_in_current_status 
  weeks = (days/7).floor
  style = ""
  if(weeks >= 2 && weeks <=4)
     style = "background-color:yellow"
  elsif(weeks >= 4 && weeks <=6)
   style = "background-color:orange"
  elsif(weeks >= 6)
    style = "background-color:#ff7744"
  end
  
   return style
end



end







