ActionController::Routing::Routes.draw do |map|
 
  map.connect 'r/:t', :controller => 'users', :action => 'reset_password'

  map.connect 'user_templates/clear_template_cache', :controller => 'user_templates', :action => 'clear_template_cache'
  map.connect 'admin',:controller=>'admin',:action=>'index'
  map.connect 'definitions',:controller=>'blanket_coi_forms',:action=>'definitions'
  map.connect 'manuscript_links',:controller=>'manuscript_types',:action=>'links'
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
#  map.resources :users

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action


  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  
  map.root :controller => "home", :action => :index

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
