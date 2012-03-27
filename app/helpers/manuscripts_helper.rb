module ManuscriptsHelper
  
def auth_respons_rev_data(attribute,use_na=false) 
  out = <<HERE
            <td class="array2">
            #{bool_display @contribution, attribute}
            <span id="#{"contribution_"+attribute + "_span"}">
            #{h @contribution.send(attribute+'_details') if @contribution.respond_to?(attribute+'_details')}
            </span>
          </td>  
HERE
  return out
end


end
