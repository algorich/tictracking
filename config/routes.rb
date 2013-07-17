TicTracking::Application.routes.draw do

  get "times_worked/index"

  resources :memberships, only: :destroy

  get 'dashboard' => 'site#dashboard'

  resources :tasks, except: [:show, :index] do
    resources :worktimes, except: [:show, :index] do
      member do
        put :stop
      end
    end
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
