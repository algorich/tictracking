TicTracking::Application.routes.draw do

  get 'dashboard' => 'site#dashboard'

  resources :tasks do
    resources :worktimes
  end

  resources :projects do
    member do
      post :change_admin
      get :team
    end
  end

  devise_for :users

  root to: 'site#index'
end
