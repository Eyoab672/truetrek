Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show] do
    collection do
      get :search
    end
  end
  root to: "cities#index"

  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  resources :cities, only: :index do
    resources :places, only: [:index, :show] do
      resources :comments, only: :create  # for existing places
    end
  end

  # Replies to comments
  resources :comments, only: [] do
    resources :replies, only: :create, controller: "replies"
    resource :vote, only: [:create, :destroy]
  end

  get 'my_travel_book', to: 'travel_books#show', as: :my_travel_book
  resources :places, only: [] do
    resources :travel_book_places, only: :create
  end
  resources :travel_book_places, only: :destroy
  resources :comments, only: [:new, :create, :destroy]  # for new places + delete



















  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
