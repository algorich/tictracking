TimeTracking::Application.routes.draw do

  resources :projects, except: [:destroy]

  devise_for :users

  root to: 'site#index'
end
