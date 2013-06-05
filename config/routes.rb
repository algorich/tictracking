TimeTracking::Application.routes.draw do
  
  resources :projects,  only: [:new, :create, :show]

  devise_for :users

  root to: 'site#index'
end
