TicTracking::Application.routes.draw do
  resources :worktimes

  resources :tasks

  resources :projects do
    member do
      post :change_admin
    end
  end

  devise_for :users

  root to: 'site#index'
end
