Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # Profile completion for OAuth users
  get "complete_profile", to: "users/profiles#complete", as: :complete_profile
  patch "complete_profile", to: "users/profiles#update_profile"
  resources :users, only: [:show] do
    collection do
      get :search
    end
    member do
      get :followers
      get :following
    end
    resource :follow, only: [:create, :destroy]
  end

  resources :notifications, only: [:index] do
    member do
      patch :mark_read
    end
    collection do
      patch :mark_all_read
    end
  end

  resources :conversations, only: [:index, :show, :new, :create, :update] do
    member do
      post :accept
      delete :decline
      get :info
      post :add_members
      delete :remove_member
      delete :leave
    end
    resources :messages, only: [:create, :destroy]
  end

  root to: "cities#index"
  get "search", to: "search#index", as: :search

  get "/pages/home", to: "pages#home"
  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  # Admin namespace
  namespace :admin do
    get "/", to: "dashboard#index", as: :root
    resources :reports, only: [:index, :show, :update, :destroy]
    resources :places, only: [:index, :show, :destroy]
    resources :users, only: [:index, :show, :destroy] do
      member do
        post :ban
        post :unban
      end
    end
    resources :comments, only: [:index, :show, :destroy]
  end

  resources :cities, only: :index do
    resources :places, only: [:index, :show] do
      resources :comments, only: :create  # for existing places
      member do
        post :regenerate_description
      end
    end
  end

  # Place reports (for users to report places)
  resources :places, only: [] do
    resources :reports, only: [:new, :create]
  end

  get  "/camera", to: "captures#new",    as: :camera
  post "/camera", to: "captures#create"


  # Replies to comments
  resources :comments, only: [] do
    resources :replies, only: :create, controller: "replies"
    resource :vote, only: [:create, :destroy]
    resources :reports, only: [:new, :create]
  end

  get 'my_travel_book', to: 'travel_books#show', as: :my_travel_book
  resources :places, only: [:new, :create, :update] do
    resources :travel_book_places, only: :create
    collection do
      get :autocomplete, to: 'places/autocomplete#index'
    end
  end
  resources :travel_book_places, only: :destroy do
    member do
      patch :toggle_pin
    end
    collection do
      delete :bulk_destroy
      patch :bulk_pin
    end
  end
  resources :comments, only: [:new, :create, :destroy]  # for new places + delete

  # Tour completion
  post 'tour/complete', to: 'tours#complete', as: :complete_tour



















  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
