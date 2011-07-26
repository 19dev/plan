Schedule::Application.routes.draw do
  # USER --------------
  # - I/O
  get  "user/giris"
  post "user/login"
  get  "user/logout"
  get  "user/home"
  # --------------------

  get  "user/lecturernew"
  post "user/lectureradd"
  get  "user/lecturershow"
  post "user/lecturershow"
  post "user/lectureredit"
  get  "user/lecturerreview"
  post "user/lecturerdel"
  post "user/lecturerupdate"
  # --------------------

  get  "user/coursenew"
  post "user/courseadd"
  get  "user/courseshow"
  post "user/courseshow"
  post "user/courseedit"
  get  "user/coursereview"
  post "user/coursedel"
  post "user/courseupdate"
  # end USER -----------

  # ADMIN
  # - I/O
  get  "admin/giris"
  post "admin/login"
  get  "admin/home"
  get  "admin/logout"
  # ---------------------

  post "admin/table"
  get  "admin/review"
  get  "admin/show"
  post "admin/show"
  post "admin/del"
  post "admin/edit"
  post "admin/update"
  get  "admin/find"
  get  "admin/new"
  post "admin/add"

  get "admin/info"
  # end ADMIN -----------

  # HOME
  #
  get  "home/index"
  get  "home/find"
  post "home/find"
  get  "home/review"
  post "home/review"
  get  "home/auto"
  post "home/auto"
  post "home/program"
  # ---------------------

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
