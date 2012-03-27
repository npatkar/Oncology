OncologyPrivate::Application.routes.draw do |map|
map.resources :statuses

  map.resources :article_submission_reviewers

 
  map.connect 'r/:t', :controller => 'users', :action => 'reset_password'

  map.connect 'user_templates/clear_template_cache', :controller => 'user_templates', :action => 'clear_template_cache'
  map.connect 'edit_user_template', :controller => 'user_templates', :action => 'edit'
  map.connect 'edit_template_inline',:controller => 'user_templates',:action=>'edit_inline'
  map.connect 'admin',:controller=>'admin',:action=>'index'
  map.connect 'definitions',:controller=>'blanket_coi_forms',:action=>'definitions'
  map.connect 'manuscript_links',:controller=>'manuscript_types',:action=>'links'
  map.connect 'user_subjects',:controller=>'users',:action=>'user_subjects'
  map.signin '/signin', :controller => 'users', :action => 'login'

  map.resources :charge_types

  map.resources :active_statuses
  map.resources :article_sections
  map.resources :emails
  map.resources :user_templates
  map.resources :degrees
  map.resources :pages
  map.resources :roles
#  map.resources :coi_forms
  map.resources :contribution_types
#  map.resources :article_submissions
  map.resources :contributions
  map.resources :manuscript_types, :member=>{:links=>:get}

  map.root :controller => "home", :action => :index
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
