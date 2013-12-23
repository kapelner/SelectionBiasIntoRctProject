StatTurk::Application.routes.draw do
  
  #experimental stuff  
  get 'task/index'
  get 'task/splash_page'
  get 'task/run_completed'
  get 'task/only_once'
  get 'task/unauthorized'
  
  get 'task/demographics'
  post 'task/demographics'
  get 'task/select_study'
  post 'task/select_study'   
  get 'task/study'
  post 'task/study' 
  get 'task/leave_comments'
  post 'task/leave_comments'  
  get 'task/mturk_submit'
  post 'task/record_nav_away'
  
  #admin stuff
  mount RailsAdmin::Engine => '/db_admin', :as => 'rails_admin'
  devise_for :admins
  devise_scope :admin do
    match "/logout" => "devise/sessions#destroy"
  end  
  root :to => 'admin#dashboard'
  match "admin/(:action)", :controller => :admin
end
