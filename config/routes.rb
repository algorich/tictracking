TicTracking::Application.routes.draw do

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
      post :change_role
      get :team
      post :add_user
      get :report
      get :filter
    end
  end

  devise_for :users

  authenticated :user do
    root to: 'site#dashboard', as: :user_root
  end

  root to: 'site#index'
end
