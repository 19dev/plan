Schedule::Application.routes.draw do
  # USER --------------
  # - I/O
  get "user/" => "user#login"
  get  "user/login"
  post "user/login"
  get  "user/logout"
  get  "user/index"
  # --------------------

  get  "user/noticenew"
  post "user/noticeadd"
  get  "user/noticeshow"
  post "user/noticeshow"
  post "user/noticeedit"
  get  "user/noticereview"
  post "user/noticedel"
  post "user/noticeupdate"
  # --------------------

  get  "user/accountpassword"
  get  "user/accountedit"
  post "user/accountedit"
  post "user/accountupdate"
  get  "user/accountshow"
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
  # --------------------

  get  "user/assignmentnew"
  post "user/assignmentadd"
  get  "user/assignmentshow"
  post "user/assignmentshow"
  post "user/assignmentedit"
  get  "user/assignmentreview"
  post "user/assignmentdel"
  post "user/assignmentupdate"
  # --------------------

  get  "user/schedulenew"
  post "user/scheduleselect"
  post "user/scheduleadd"
  get  "user/scheduleshow"
  post "user/scheduleshow"
  post "user/scheduleedit"
  get  "user/schedulereview"
  post "user/scheduledel"
  # --------------------
  # end USER -----------

  # ADMIN
  # - I/O
  get "admin/" => "admin#login"
  get  "admin/login"
  post "admin/login"
  get  "admin/home"
  get  "admin/logout"
  # ---------------------
  get  "admin/info"
  get  "admin/help"
  # database
  get  "admin/database"
  get  "admin/export"
  post "admin/export"
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
  # system
  get  "admin/report"
  get  "admin/department"
  get  "admin/period"
  get  "admin/class"
  get  "admin/day"
  # end ADMIN -----------

  # HOME
  root :to => 'home#index'
  get "home/" => "home#index"
  get  "home/index"

  get 'home/lecturershow' => 'home#lecturershow'
  get 'home/lecturershow/:period_id/:lecturer_id' => 'home#lecturershow'

  get 'home/departmentshow' => 'home#departmentshow'
  get 'home/departmentshow/:period_id/:department_id/:section' => 'home#departmentshow'

  get 'home/departmentreview' => 'home#departmentreview'
  get 'home/departmentreview/:period_id/:department_id' => 'home#departmentreview'

  get  "home/lecturer"
  get 'home/lecturerplan' => 'home#lecturerplan'
  get 'home/lecturerplan/:period_id/:lecturer_id' => 'home#lecturerplan'
  get 'home/lecturerplanpdf/:period_id/:lecturer_id' => 'home#lecturerplanpdf'

  get  "home/class"
  get 'home/classplan' => 'home#classplan'
  get 'home/classplan/:period_id/:classroom_id' => 'home#classplan'
  get 'home/classplanpdf/:period_id/:classroom_id' => 'home#classplanpdf'
  post  'home/classplanpdf'
  get 'home/classplanpdfs' => 'home#classplanpdfs'

  get  "home/department"
  get 'home/departmentplan' => 'home#departmentplan'
  get 'home/departmentplan/:period_id/:department_id/:year/:section' => 'home#departmentplan'
  get 'home/departmentplanpdf/:period_id/:department_id/:year/:section' => 'home#departmentplanpdf'

  get  "home/about"
  get  "home/help"
  # ---------------------

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   get 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   get 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
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
  # get ':controller(/:action(/:id(.:format)))'
end
