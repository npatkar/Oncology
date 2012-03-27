OncologyPrivate::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
end
module App
  module Config
    @@private_key = RAILS_ROOT + '/config/keys/private.pem'
    @@public_key  = RAILS_ROOT + '/config/keys/public.pem'

    @@gateway_login = '3Jwsj2Xt93'
    @@gateway_password = '7V67Y66Nxj8j9pcD'
    @@gateway_test = true
    @@gateway_cim_profile_prefix = 'to1'

    #@@finance_email = 'marty3rd@alphamedpress.com'
    @@finance_email = 'anthony@sageserver.com'

    @@reviewer_from_email = 'Nicole Weber <Nicole.Weber@TheOncologist.com>'

    #@@editorial_office_email = 'Nicole Weber <Nicole.Weber@TheOncologist.com>'
    @@editorial_office_email = 'anthony@sageserver.com'

    #@@managing_editor_email = 'Ann Murphy <Ann.Murphy@TheOncologist.com>'
    @@managing_editor_email = 'anthony@sageserver.com'

    @@from_email = 'On behalf of the editorial office of The Oncologist <Editors@TheOncologist.com>'

    @@test_email = "brian@sageserver.com"
    #@@submissions_email = ['manuscripts@theoncologist.com', 'marty3rd@alphamedpress.com']

    #@@submissions_email = ['anthony@sageserver.com']
    #$@@submissions_email = ['anthony@sageserver.com', 'amptest@sageserver.com']
    @@submissions_email = ['brian@sageserver.com', 'anthony@sageserver.com']

    @@cadmus_error_email = ['brian@sageserver.com','foxx@email.unc.edu']

    #@@base_url = 'https://manuscriptsubmissions.theoncologist.com/'
    # For testing, change in production!
    @@base_url = 'http://192.168.1.3:3000/'

    @@date_mask = '%m/%d/%y'

    class_variables.each do |v|
      mattr_accessor v[(2..-1)]
    end
  end
end

