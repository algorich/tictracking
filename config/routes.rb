TicTracking::Application.routes.draw do
  resources :tasks

  resources :projects

  devise_for :users

  root to: 'site#index'
end
