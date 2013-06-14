TicTracking::Application.routes.draw do

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
