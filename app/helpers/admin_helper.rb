module AdminHelper
  
  def get_manuscript_sequence
     config = Configuration.find_by_name("manuscript_sequence")
     curr_year= Time.now.strftime("%y")
     val = config.value
     tok_1 = nil
     if(val && val.match(/^T\d{2}-\d+$/))
        toks = val.split("-")
        tok_1 = toks[0]
        tok_2 = toks[1]
        unless "T#{curr_year}" == tok_1 
          config.update_attributes({:value=>"T#{curr_year}-1"})
        end
      else
          config.update_attributes({:value=>"T#{curr_year}-1"})
      end
      return config.value
  end
  
  
  
  def get_available_reviewer_actions(asr)
    #TODO make these strings constants !!!!!
       actions = Array.new
       status_key = asr.current_status_key
       case status_key
        when "reviewer_not_yet_invited"
           actions << link_to_function("Send Invite","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/invite_to_review/#{asr.id}',null,true)")
           if current_user.has_admin?
             actions <<  link_to_function("Send Packet","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/reviewer_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Urgent Comments Reminder","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/urgent_message/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Packet Check In Message","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/check_in_for_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send First Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/first_reminder_for_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Second Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/second_reminder_for_packet/#{asr.id}',null,true)")
           end
        when "reviewer_invited_awaiting_response"
           actions << link_to_function("Resend Invite","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/invite_to_review/#{asr.id}',null,true)")
           actions << link_to_function("Send Request Response Reminder","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/request_response_reminder/#{asr.id}',null,true)")
           if current_user.has_admin?
             actions <<  link_to_function("Send Packet","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/reviewer_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Urgent Comments Reminder","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/urgent_message/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Packet Check In Message","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/check_in_for_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send First Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/first_reminder_for_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Second Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/second_reminder_for_packet/#{asr.id}',null,true)")
           end
         when "reviewer_accepted"
           actions <<  link_to_function("Send Packet","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/reviewer_packet/#{asr.id}',null,true)")
           if current_user.has_admin?
             actions <<  link_to_function("Send Urgent Comments Reminder","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/urgent_message/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Packet Check In Message","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/check_in_for_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send First Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/first_reminder_for_packet/#{asr.id}',null,true)")
             actions <<  link_to_function("Send Second Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/second_reminder_for_packet/#{asr.id}',null,true)")
           end
        when "reviewer_need_comments"
           actions <<  link_to_function("Send Urgent Comments Reminder","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/urgent_message/#{asr.id}',null,true)")
           actions <<  link_to_function("Send Packet Check In Message","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/check_in_for_packet/#{asr.id}',null,true)")
           actions <<  link_to_function("Send First Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/first_reminder_for_packet/#{asr.id}',null,true)")
           actions <<  link_to_function("Send Second Reminder For Comments","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/second_reminder_for_packet/#{asr.id}',null,true)")
      
         end
       unless status_key == "reviewer_given_up"
          actions <<  link_to_remote("Give Up On Reviewer",:url=>"/admin/give_up_on_reviewer/#{asr.id}",:confirm => "Please confirm you want to give up on this reviewer.")
        end
        
       actions << "None" if actions.empty?
      return actions
  end
  
  
  def coauthor_coi_reminder_popup_link(contr)
    link_to_function("Send Coi Reminder","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/coauthor_coi_message/#{contr.id}',null,true)")   
  end
  
  def generic_email_popup_link(user)
    link_to_function("Send Message","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/generic_message/#{user.id}',null,true)")   
  end
  
   def reviewer_coi_reminder_popup_link(rev)
    link_to_function("Send Coi Reminder","AjaxPopup.OpenBoxWithUrl(this,true,'/admin/reviewer_coi_message/#{rev.id}',null,true)")   
  end
  
  
  
  def submission_listing_color(asub)
    if asub.admin_urgent
      return "urgent"
    elsif asub.invited
      return "invited"
    else
      return ""
     end
  end
  
end
