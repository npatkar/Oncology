class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # allows direct login with a "token" 
  before_filter :login_direct 

  before_filter :load_params

  before_filter :load_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
 # protect_from_forgery  :secret => '98c658495456442998147309dbd17c72', :only => [:create, :update, :destroy]
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log(in this case, all fields with names like "password"). 
  filter_parameter_logging(:password,:credit,:num)#{ |k,v| if k =~ /num/i ;v.slice!(0,(v.length-4)) ;elsif k =~ /cvv/i; v.slice!(1,3) ;end}
#filter_parameter_logging (:password){ |k,v| if k =~ /num/i ;v.to_s.reverse! ;elsif k =~ /cvv/i; v.reverse! ;end}

  #self.allow_forgery_protection = false
  
  private


  # add an entry to track certain actions from our controllers
  # if we have certain instance variables, auto-load them into the audit trail attributes
  # We don't auto-load the user acted on: 'user_acted_on_id'
  def add_audit_trail(options = {})
    #logger.info("*** Adding audit trail. options: #{options.inspect}")
    return false unless current_user and options[:details] 
    if current_user
	options[:user_id] = current_user.id    
    else
	options[:user_id] = 0   
    end	

    if @article_submission
      options[:article_submission_id] ||= @article_submission.id
    end
    if @user
      options[:user_acted_as_id] ||= @user.id
    end
    if @contribution
      options[:contribution_id] ||= @contribution.id
    end
    if @coi_form
      options[:coi_form_id] || @coi_form.id
    end
   
    audit_trail = AuditTrail.create(options)
    logger.info("*** Created audit trail: #{audit_trail.inspect}")
  end


  # For each of these vars, if there is a var + '_id' in the params hash, attempt to load an instance variable of the same name
  # by looking in the db for that classname, using var + '_id' as the id of an object of that class
  # ATTN: NEVER LOAD USER_ID as @user!!! This would compromise the system, as @user is used to operate on specific users
  def load_params
    vars = ['article', 'article_submission']
    vars.each { |v| load_param(v) }
  end

  # if there is a p + '_id' in the params hash, attempt to load an instance variable of the same name
  # by looking in the db for that classname, using p + '_id' as the id of an object of that class
  def load_param(p)
    if params.has_key?(p + '_id')
      #logger.info("*** looking to load: #{p + '_id'}")
      begin
        instance_variable_set(('@' + p).to_sym, p.camelize.constantize.find(params[p + '_id']))
        #logger.info("**** autoloaded an instance of #{p.camelize} with an id of #{params[p + '_id']} ****")
      rescue
        logger.info("**** Couldn't find an instance of #{p.camelize} with an id of #{params[p + '_id']} ****")
      end
    end
  end

  # if we have a 't' paramater, look for the token, and log them in automatically
  def login_direct
    if token = params[:t]
      old_user = current_user
      user = User.find_by_secret_token(token)
      logger.info("finding token: -#{token}- user: -#{user ? user.name : 'nil'}-")
      if ! user.nil?
        if current_user && current_user.has_role?(:user)
          add_audit_trail(:details => "Impersonating user", :user_acted_on_id => user.id)
        end
        logger.info("*** direct login of user with id: #{user.id}")
        self.current_user = user     # Sign them in
      else
        handle_bad_token
        return false
      end
    end
  end

 
  def handle_bad_token
     logger.info("!!! BAD TOKEN, POSSIBLE HACK ATTEMPT")
     self.current_user.forget_me if logged_in?
     url = request.request_uri
     url.gsub!(/t=\w+/,"")
     session[:return_to] = url
     flash[:notice] = "Your sign in link has expired. Please sign in with your username and password to access this page."
     redirect_to :controller => :users, :action => :login, :from_token => true
  end
  
  # litespeed way to send a file with an internal redirect
  def sendfile_via_litespeed(path)
    #@file_to_send = session[:filename]                 # a session variable set in a view or other function
    #filename = path      # create the URI, must be under /public     
    headers["Location"] = path             # set the 'Location header
    redirect_to(path)                      # redirect
  end

  
  def add_conditions(conditions, new_condition, values = nil)
    conditions[0] = conditions[0] + " AND #{new_condition}"
    conditions << values if values
    conditions.flatten!
    #logger.info("***** inside add_conditions: conditions: #{conditions.inspect}")
  end

  
  def must_be_admin
    unless current_user
      logger.info("*** non-logged in access to must_be_admin action")
      redirect_to :controller => :users, :action => :login
      return false
    end
    if current_user.has_admin?
      true
    else
      flash[:notice] = "You do not have enough privileges to access this function. The relevant parties have been notified. Your IP: #{request.remote_ip}. User ID: #{current_user.id}"
      logger.info("Security Alert!! Unsuccessful attempt to access admin features. IP: #{request.remote_ip}, User ID: #{current_user.id}")
      redirect_to :controller => :users, :action => :login 
      false
    end
  end
  
  def load_user
     @user = current_user
  end
 
  def redirect_back_or(default)
    begin
      redirect_to :back
    rescue
      redirect_to :controller=>default, :id=>current_user.id
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
  end
  
  #alias :rescue_action_locally :rescue_action_in_public

end
