class UsersController < ApplicationController
  
 
  before_filter :login_required, :except => [:login, :signup, :forgot_password, :direct]
  #before_filter :load_user, :except => [:login, :signup, :forgot_password, :reset_password, :direct]
  
  before_filter :must_be_admin, :except => [:login, :signup, :forgot_password, :reset_password, :direct, :edit, :update, :logout]
  
  before_filter :check_filter_params, :only => [:index, :update_users_list]
  before_filter :load_users, :only => [:index, :update_users_list]
   

  def index
    add_audit_trail(:details => "Viewed the users listing page.")
  end
  
  
  def disable_user
      @user = User.find(params[:id])
      if(@user.update_attribute(:disabled,true))
        id = "user_#{@user.id}"
        u_id = "user_forms_#{@user.id}"
        render :js=>"$('#{id}').hide();$('#{u_id}').style.display='none')"
      else
        render :js=>"alert('Request Failed')"
      end
  end
  
   def enable_user
      @user = User.find(params[:id])
      if(@user.update_attribute(:disabled,false))
           render :js=>"$('#{id}').syle.textDecoration = ''"
      else
         render :js=>"alert('Request Failed')"
      end
  end
  
  def supress_email_sending
    @user = User.find(params[:id])
    respond_to do |format|
      if(@user.update_attribute(:supress_email,true))
        format.js
      else
        format.js render :text=>"Request Failed"
      end
    end
  end
  
  def enable_email_sending
    @user = User.find(params[:id])
    respond_to do |format|
      if(@user.update_attribute(:supress_email,false))
          format.js
      else
         format.js render :text=>"Request Failed",:status => 500
      end
    end 
  end
  
   def reviewer_subjects
    respond_to do |format|
      format.html # index.html.erb
      format.js {render :partial=>'subjects'}
    end
  end
  
  
  
  def update_users_list
    
     respond_to do |format|
      format.html {render :action=>'index'}
      format.js{
          render :update, :type =>'text/javascript'  do |page|
            page.replace_html 'users', :partial => 'users'
          end
      }
    end
    add_audit_trail(:details => "Refreshed the users listing page.")
  end
  
  
  def direct
    token = params[:t]
    user = User.find_by_secret_token(token)
    if ! user.nil?
      logger.info("*** users/direct found user with id: #{user.id}")
      self.current_user = user     # Sign them in
      logger.info("params[:dest_controller] = #{params[:dest_controller]} - params[:dest_action] = #{params[:dest_action]}")
      params.has_key?(:dest_controller) && @dest_controller = params[:dest_controller]
      params.has_key?(:dest_action) && @dest_action = params[:dest_action]
      if @dest_controller || @dest_action
        redirect_to :controller => @dest_controller, :action => @dest_action
        return
      end
      
      flash[:notice] = "Blanket Financial Disclosure forms can be accessed from the 'Blanket Financial Disclosure Form' link above. Any manuscript Financial Disclosure forms you have waiting will be listed below.  Thank You!"
      redirect_to :controller=>'manuscripts', :id=>user.id
      return
    end
    
    redirect_to :controller=>'home'
  end


  def forgot_password
    return unless request.post?
    
    if user = User.find_by_email(params[:email].downcase)
      user.reset_secret_token
      begin
        user.save(false) or raise(StandardError, "Couldn't save user for reset password link")
        Notifier.deliver_reset_password_link(user)
        flash.now[:notice] = "An email has been sent to: #{params[:email]} with instructions on how to reset your password. If you do not receive it in your inbox within a few minutes, please check your bulk email or spam folder."
      rescue
        flash.now[:notice] = "There was a problem sending your reset password link. Please contact webmaster@TheOncologist.com."
        logger.info("*** Couldn't send assword reset link: #{$!}")
      end
    else
      flash.now[:notice] = "I'm sorry. I could not find a person with that email address."
    end
  end
 
 
  # We are coming from a reset password link, reset the password, and redirect to login
  def reset_password
    
    # We're coming from a reset_password link
    # TODO: (Since we're checking the in the application controller for this param and logging in, we prob don't need this check anymore)
    #if params.has_key?(:t)
      #logger.info("**** looking for secret_token #{params[:t]}")
      #if @user = User.find_by_secret_token(params[:t])
      #  self.current_user = @user
      #else
      #  flash[:notice] = "The link you have is invalid."
      #  redirect_to :action=>'forgot_password'
      #end  

      # We're coming from the new password submission page
      # TODO: Remove this logic. We no longer have a new password submission page. This is now done when creating the user
    #else
      #redirect_to :action=>'forgot_password' unless request.post? or params[:user][:plain_password].blank?
    if request.post? and params[:user] and params[:user][:plain_password] and !params[:user][:plain_password].blank? 
      @user.plain_password = params[:user][:plain_password]
      @user.plain_password_confirmation = params[:user][:plain_password_confirmation]
      if @user.save(false)
        flash[:notice] = "Your password has been updated"
        redirect_to :controller=>'manuscripts', :id=>@user.id
      else
        flash[:now] = 'There was a problem updating your password' 
      end
    end
  end
  
  
  def set_login_info
    return unless request.post?
  end


  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:username], params[:plain_password])
    logger.info("logging in current_user: #{self.current_user}")
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      
      # If they were created by another user as a coauthor, and they haven't logged in yet, then still can be edited by that user
      # Now we disallow any edits by that user
      unless self.current_user.user_can_edit.nil?
        self.current_user.user_can_edit = nil
        # Save without validation, as we always want to disallow future edits by creating user, even if invalid record
        self.current_user.save(false)
      end
      
      redirect_back_or_default(:controller=>'manuscripts', :id=>current_user.id )
      if current_user.has_admin?
        add_audit_trail(:details => 'User logged in.')
      end
    else
      flash[:notice] = "This email address / password combination was not found in our records."
    end
  end

  def signup
    @user = User.new(params[:user])
    
    return unless request.post?
    
    @user.set_defaults
    @user.create_by_ip = request.remote_ip
    if current_user
    	@user.create_by_id = current_user.id    
    else
	@user.create_by_id = 0   
    end
    @user.save!
    self.current_user = @user
    
    redirect_to :controller => 'manuscripts'

    # Always edit their user info when signing up...
    #redirect_to :action => 'edit', :id => self.current_user.id
    #redirect_back_or_default(:controller => '/users', :action => 'edit', :id => self.current_user.id)
    flash[:notice] = "Thanks for signing up!"
		
    rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  
  def edit
    # Admins edit whoever they want, users only edit the current_user
    if current_user.has_admin? and params[:id]
      @user = User.find(params[:id])
    end
  end
   
  def update
    # Admins edit whoever they want, users only edit the current_user
    if current_user.has_admin? and params[:id]
      @user = User.find(params[:id])
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Your information was successfully updated.'
    #  if(@user.has_role?:reviewer)
         save_reviewer_subjects(params[:article_section_ids]||[],@user)
    #  end
      # Now we can go to where they intended to go...
      if(current_user.has_admin?)
          redirect_to :action=>:edit,:param => @user.id
      else
      redirect_back_or_default :controller=>'manuscripts'
      
      end
    else
      render :action=>"edit", :id=>@user.id
    end
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/home', :action => 'index')
  end
  
  # Add a bunch of users, setting defaults and temp scrambled passwords
  # Checks users to be bulk-added, ensures no email addresses are duplicated, and first/last names are completed
  def check_users
    dups = valids = invalid_format = total = 0
    @summary = '<ol>'
    each_user_line(params[:users_to_add]) do |line|
      total += 1
      (status, email, first_name, last_name) = check_new_user(line)
      case status
        when 'already_exists'
           line_out = "email: #{email} already exists in the system, won't be added, but may add new roles."
           dups += 1
        when 'invalid_format'
           line_out = "#{line} Unrecognized format, won't be added"
           invalid_format += 1
        when 'good'
           line_out = "email-(#{email})  first_name-(#{first_name})  last_name-(#{last_name})"
           valids += 1
       end
	
      @summary += '<li>' + line_out + '</li>'
    end
    @summary += '</ol>'
    
    @summary = "<p>Out of #{total} users to add: #{valids} are valid, #{dups} already exist, and #{invalid_format} are in the wrong format.</p>" + @summary
    render :update do |page|
      page.replace_html :summary, "<h2>Summary</h2>" + @summary
    end

  end
  
  def strip_problem_users
    stripped = total = 0
    @users_to_add = ''
    @summary = '<ol>'
    each_user_line(params[:users_to_add]) do |line|
      total += 1
      (status, email, first_name, last_name) = check_new_user(line)
      case status
        when 'already_exists'
           #line_out = "Removing - #{line} - Email already exists"
           #stripped += 1
        when 'invalid_format'
          line_out = "Removing - #{line} - Invalid Format"
          stripped += 1
        when 'good'
          line_out = nil
           @users_to_add += "#{email}  #{first_name}  #{last_name}"
      end
		
      unless line_out.nil?
        @summary += ('<li>' + line_out + '</li>')
      end
    end
    @summary += '</ol>'
    
    @summary = "<p>Out of #{total} users to add: #{stripped} have been stripped.</p> #{@summary}"
    render :update do |page|
      page.replace_html :summary, "<h2>Summary</h2> #{@summary}"
      page.replace_html :users_to_add_wrapper, :partial => 'users_to_add'
    end
  end
  
  def add_users
    dups = valids = invalid_format = total = errors = 0
    @summary = '<ol>'
    each_user_line(params[:users_to_add]) do |line|
      total += 1
      (status, email, first_name, last_name) = check_new_user(line)
      case status
        when 'already_exists'
           line_out = "'#{line}' already exists in the system, won't be added, but may add roles"
           dups += 1
           add_given_role(email)
           User.find_by_email(email).update_attributes(:first_name => first_name, :last_name => last_name)
        when 'invalid_format'
           line_out = "'#{line}' Unrecognized format, won't be added"
           invalid_format += 1
        when 'good'
           line_out = "email-(#{email})  first_name-(#{first_name})  last_name-(#{last_name})"
           if create_user(email, first_name, last_name)
             line_out += "#{email}, #{first_name}, #{last_name} - was created..."
             valids += 1
           else
             line_out += "***** Problem -  #{email}, #{first_name}, #{last_name} - Was not created successfully! *****"
             errors += 1
           end
       end
      @summary += "<li>#{line_out}</li>"
    end
    @summary += '</ol>'

    @summary = "<p>There were #{errors} users not created due to errors.<p>" + @summary
    @summary = "<p>Out of #{total} users to add: #{valids} were created, #{dups} already exised and were not added, and #{invalid_format} were in the wrong format.</p>" + @summary

    render :update do |page|
      page.replace_html :summary, "<h2>Summary</h2>" + @summary
    end
    add_audit_trail(:details => "Bulk added users.")
  end
  
  def destroy_users
    process_user_ids do |u_id, page| 
      add_audit_trail(:details => "Deleting user", :user_acted_on_id => u_id)
      if User.destroy(u_id)
        page.select("#user_#{u_id} input").first.disabled = true
        page.hide("user_#{u_id}")
      end
    end
  end
  
  def send_coi_links
    process_user_ids do |u_id, page|
      add_audit_trail(:details => "Sending blanket COI links to user", :user_acted_on_id => u_id)
      email_hash = {:category=>EmailLog::SENT_BLANKET_COI_REMINDER}
      user = User.find(u_id)
      if Notifier.deliver_blanket_coi_link(user,email_hash)
        user.email_logs.create(email_hash)
      else
         false
      end
      
    end
  end

  def add_to_role
    role = Role.find(params[:act_on_role_id])
    process_user_ids do |u_id, page|
      add_audit_trail(:details => "Adding role '#{role.role_title}' to user", :user_acted_on_id => u_id)
      if User.find(u_id).roles << role
        page.replace_html("user_#{u_id}_roles", User.find(u_id).disp_roles)
      end
    end
  end
  
  def remove_from_role
    role = Role.find(params[:act_on_role_id])
    process_user_ids do |u_id, page| 
      add_audit_trail(:details => "Removing role '#{role.role_title}' from user", :user_acted_on_id => u_id)
      if User.find(u_id).roles.delete(role)
        page.replace_html("user_#{u_id}_roles", User.find(u_id).disp_roles)
      end
    end
  end
  
  
  ##################################################################################################
  private
  ##################################################################################################
 
    def save_reviewer_subjects(ids,user)
      subjects = user.article_sections
      delete_list = Array.new
      subjects.each do|s|
        if(!ids.include?s.id)
          delete_list << s
        else
          ids.delete s.id
         end
      end   
    
      delete_list.each do|i|
        user.article_sections.delete(i)
        ids.delete i.id
      end
      
      ids.each do |id|
        user.article_sections << ArticleSection.find(id) 
      end  
      return nil
  end
  
  def check_filter_params
    @show_disabled = !params[:show_disabled].blank? ? params[:show_disabled] == 'true' : false
    @sort_by = 'email'    # default
    if  User.columns.collect {|c| c.name}.include?(params[:sort_by])
      @sort_by = params[:sort_by]
    elsif params.has_key?('sort_by') && params['sort_by'] == 'blanket_coi'
      @sort_by = 'blanket_coi'
    end
    
    @direction = 'DESC'   # default
    if params.has_key?('direction') && params['direction'] == 'ASC'
      @direction = 'ASC'
    end
    
    @role_id = 0  # default
    if params.has_key?('role_id') && params[:role_id].to_i > 0
      @role_id = params[:role_id].to_i
    end
    
    @per_page = 25  # default
    if params.has_key?('per_page') && params[:per_page].to_i > 0
      @per_page = params[:per_page].to_i
    end

    @blanket_coi_date_range = 0   # default
    if params.has_key?('blanket_coi_date_range') && params[:blanket_coi_date_range].to_i >= 0
      @blanket_coi_date_range = params[:blanket_coi_date_range].to_i
    end
    
    @blanket_coi_committed = 'all'    # default
    if params.has_key?('blanket_coi_committed')
      if params[:blanket_coi_committed] == 'yes'
        @blanket_coi_committed = 'yes'
      elsif params[:blanket_coi_committed] == 'no'
        @blanket_coi_committed = 'no'
      else
        # Doesn't make sense to specify a date range while not filtering on 'committed'
        @blanket_coi_date_range = 0
      end
    end
    
    @search_string = nil  # default
    if params.has_key?(:search_string)
      @search_string = params[:search_string].gsub(/[^a-zA-Z.-_@0-9]/, '')
    end   
 
    @update_url_wo_action  = { 
                     :sort_by                 => @sort_by, 
                     :direction               => @direction,
                     :role_id                 => @role_id, 
                     :blanket_coi_committed   => @blanket_coi_committed, 
                     :blanket_coi_date_range  => @blanket_coi_date_range,
                     :per_page                => @per_page }

    @update_url  = { :action                  =>'update_users_list', 
                     :sort_by                 => @sort_by, 
                     :direction               => @direction,
                     :role_id                 => @role_id, 
                     :blanket_coi_committed   => @blanket_coi_committed, 
                     :blanket_coi_date_range  => @blanket_coi_date_range,
                     :per_page                => @per_page }
  end
  
  
  
  
  def load_users
    joins = []
    includes = []
    conditions = ['1'] 

    if @role_id > 0
      joins << :roles
      add_conditions(conditions, 'user_to_role.role_id = ?', @role_id.to_s)
    else
      includes << :roles
    end

    if @search_string
      add_conditions(conditions, '(users.email LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ?)', ["%#{@search_string}%", "%#{@search_string}%", "%#{@search_string}%"])
    end
    
    
    if @show_disabled
       add_conditions(conditions,'users.disabled = ?',true)   
    else
       add_conditions(conditions,'(users.disabled is ? OR users.disabled = ?)',[nil,false])   
    end
    # We are filtering by comitted and maybe by date
    if @blanket_coi_committed != 'all'
      joins << :blanket_coi_forms

      
      # We ARE NOT filtering by date, ONLY blanket_coi.committed
      if @blanket_coi_date_range == 0
        if @blanket_coi_committed == 'yes'
          add_conditions(conditions, 'coi_forms.committed IS NOT NULL')
        else
          sql = "SELECT users.* 
                 FROM users 
                 JOIN user_to_role ON users.user_id = user_to_role.user_id
                 WHERE NOT EXISTS (
                       SELECT * FROM coi_forms 
                       WHERE 
                         users.user_id = coi_forms.user_id AND 
                         coi_forms.committed IS NOT NULL 
                 )"

          sql += " AND user_to_role.role_id = #{@role_id}"  if @role_id > 0
#          if @show_disabled
#             sql += " AND users.disabled = true" 
#          else
#             sql += " AND (users.disabled is null"
#          end
          sql += " AND (users.email LIKE '%#{@search_string}%' OR users.first_name LIKE '%#{@search_string}%' OR users.last_name LIKE '%#{@search_string}%')"  if @search_string
        end

      # We ARE filtering by date and blanket_coi.committed
      else
        if @blanket_coi_committed == 'yes'
          add_conditions(conditions, 'coi_forms.committed > (DATE_SUB(NOW(), INTERVAL "?" DAY))', @blanket_coi_date_range)
        else
          # filter on role_id as well
          sql = "SELECT users.* 
                 FROM users 
                 JOIN user_to_role ON users.user_id = user_to_role.user_id
                 WHERE NOT EXISTS (
                       SELECT * FROM coi_forms 
                       WHERE 
                         users.user_id = coi_forms.user_id AND 
                         coi_forms.committed is NOT NULL 
                         AND coi_forms.committed > (DATE_SUB(NOW(), INTERVAL #{@blanket_coi_date_range} DAY))
                 )"

          sql += " AND user_to_role.role_id = #{@role_id}" if @role_id > 0
#           if @show_disabled
#             sql += " AND users.disabled = true" 
#          else
#             sql += " AND users.disabled !=true"
#          end
          sql += " AND (users.email LIKE '%#{@search_string}%' OR users.first_name LIKE '%#{@search_string}%' OR users.last_name LIKE '%#{@search_string}%')"  if @search_string
        end
      end

    else
      includes << :blanket_coi_forms
    end

    #logger.info ("**** sql: #{sql}")
    #logger.info ("**** conditions: #{conditions.inspect}")
    if sql
      @users = User.paginate_by_sql(sql, :page => params[:page], :per_page => @per_page)
      
    else
      @users = User.paginate :page => params[:page], :per_page => @per_page, :joins=>joins, :include=>includes, :conditions=>conditions, :order => "users.#{@sort_by} #{@direction}"
    end


end


  def check_new_user(line)
    # Regex to match "email-address  first-name  last name" with optional quotes around the names
    if m = line.match(/^\s*["']?([-\w'._]+\@[-\w._]+\.\w+)["']?,?\s+["']?([-\w._']+)["']?,?\s+["']?([-\w._'].*[-\w._'])["']?\s*$/)
       (email, first_name, last_name) = m[1..3]
       if User.exists?(:email => email)
         return :already_exists, email, first_name, last_name
       else
         return :good, email, first_name, last_name
       end
    else
       return :invalid_format
    end
  end

  
  
  def each_user_line(text)
    text.scan(/^(.*)$/).each do |line|
       next if line[0].match(/^\s*$/) # skip blank lines
       yield(line[0])
   end
  end
  
  
  def process_user_ids
    render :update do |page|
      if params[:user_ids]
        params[:user_ids].each do |u_id|
          page.replace_html("user_#{u_id}_status", :partial=>'/layouts/processing')
          begin 
            if yield(u_id, page)
              page.replace_html("user_#{u_id}_status", :partial=>'/layouts/check_small')
#              unless page["user_#{u_id}"].nil?
#                page.replace_html("user_#{u_id}_status", '')
                 page.select("#user_#{u_id}").first.visual_effect(:highlight)
#              end
            else
              page.replace_html("user_#{u_id}_status", :partial=>'/layouts/x_small')
            end
          rescue
            page.replace_html("user_#{u_id}_status", :partial=>'/layouts/x_small')
          end
          page.select("#user_#{u_id} input").first.checked = false
        end
      end
    end
  end
  
  
  
  def create_user(email, first_name, last_name)
    user = User.new({:first_name => first_name, 
      :last_name => last_name,
      :email => email,
      :create_by_id => self.current_user.id,
      :auto_created => false})
    user.set_defaults
    user.create_by_ip = request.remote_ip
    user.set_temp_password
    
    unless user.save(false)
      logger.info("errors creating bulk users: #{user.errors.inspect}")
      return false
    end
   
    add_given_role(email) 
  end

  def add_given_role(email)
    if params.has_key?('role_id') and params[:role_id].to_i > 0
      u = User.find_by_email(email)
      logger.info("*** adding role #{params[:role_id]} to user: #{u.email}, email: #{email}")
      RoleInstance.create(:user_id => u.id, :role_id => params[:role_id].to_i)
    end
  end
end
