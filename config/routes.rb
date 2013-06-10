TimeTracking::Application.routes.draw do
  resources :worktimes

  resources :tasks

  resources :projects

  devise_for :users

  root to: 'site#index'
end
