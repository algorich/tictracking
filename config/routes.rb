TimeTracking::Application.routes.draw do

  resources :projects

  devise_for :users

  root to: 'site#index'
end
