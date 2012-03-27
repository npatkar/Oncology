#require 'active_support'
#
#module App
#  module Config
#    @@private_key = RAILS_ROOT + '/config/keys/private.pem'
#    @@public_key  = RAILS_ROOT + '/config/keys/public.pem'
#
#    @@gateway_login = '3Jwsj2Xt93'
#    @@gateway_password = '7V67Y66Nxj8j9pcD'
#    @@gateway_test = true
#    @@gateway_cim_profile_prefix = 'to1'
#
#    #@@finance_email = 'marty3rd@alphamedpress.com'
#    @@finance_email = 'anthony@sageserver.com'
#
#    @@reviewer_from_email = 'Nicole Weber <Nicole.Weber@TheOncologist.com>'
#
#    #@@editorial_office_email = 'Nicole Weber <Nicole.Weber@TheOncologist.com>'
#    @@editorial_office_email = 'anthony@sageserver.com'
#
#    #@@managing_editor_email = 'Ann Murphy <Ann.Murphy@TheOncologist.com>'
#    @@managing_editor_email = 'anthony@sageserver.com'
#
#    @@from_email = 'On behalf of the editorial office of The Oncologist <Editors@TheOncologist.com>'
#
#    #@@submissions_email = ['manuscripts@theoncologist.com', 'marty3rd@alphamedpress.com']
#
#    #@@submissions_email = ['anthony@sageserver.com']
#    #$@@submissions_email = ['anthony@sageserver.com', 'amptest@sageserver.com']
#    @@submissions_email = ['brian@sageserver.com', 'anthony@sageserver.com']
#
#    @@cadmus_error_email = ['brian@sageserver.com', 'anthony@sageserver.com']
#
#    #@@base_url = 'https://manuscriptsubmissions.theoncologist.com/'
#    # For testing, change in production!
#    @@base_url = 'http://67.205.118.70:3000/'
#
#    @@date_mask = '%m/%d/%y'
#
#    class_variables.each do |v|
#      mattr_accessor v[(2..-1)]
#    end
#  end
#end
