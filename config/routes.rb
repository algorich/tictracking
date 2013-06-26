TicTracking::Application.routes.draw do

  get 'dashboard' => 'site#dashboard'

  resources :tasks do
    resources :worktimes
  end

  resources :projects do
    member do
      post :change_admin
      get :team
      post :add_user
    end
  end

  devise_for :users

  authenticated :user do
    root :to => 'site#dashboard'
  end

  root to: 'site#index'
end
