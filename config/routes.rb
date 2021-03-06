ProjectSignups::Application.routes.draw do

  # Authentication  
  devise_for :admins, 
  :controllers => { :registrations => "registrations", :sessions => "sessions" }, 
  :path_names => { :sign_in => "signin", :sign_out => "signout", :sign_up => "register" }
  
  devise_scope :admin do
    get "signin" => "sessions#new", :as => :sign_in 
    get "signout" => "sessions#destroy", :as => :sign_out
    #get "admins/register" => "registrations#new", :as => :sign_up
    #post "admins/register" => "registrations#create", :as => :register
  end



  resources :project_preferences

  resources :projects
  get 'projects_bulk_import' => "projects#bulk_import"
  post 'projects_bulk_import' => "projects#bulk_create", :as => :bulk_create
  get 'assignments' => "projects#assignments", :as => :project_assignments

  resources :groups

  resources :students

  resources :signups

  resources :team_evaluations

  match 'admin' => 'admin#index', :as => :admin
  match 'admin/update_project_preferences' => 'admin#update_project_preferences', :as => :admin_update_project_preferences
  match 'admin/create_iteration' => 'admin#create_iteration', :as => :admin_create_iteration
  match 'admin/delete_iteration' => 'admin#delete_iteration', :as => :admin_delete_iteration
  match 'admin/update_team_evaluation_path' => 'admin#update_team_evaluation', :as => :admin_update_team_evaluation
  match 'admin/email_team_evaluations' => 'admin#email_team_evaluations', :as => :admin_email_team_evaluations
  match 'admin/show_iteration_evaluations' => 'admin#show_iteration_evaluations', :as => :admin_show_iteration_evaluations
  
  root :to => "home#index"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
