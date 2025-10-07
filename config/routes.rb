Rails.application.routes.draw do
  get "pc_cases/index"
  get "pc_cases/show"
  get "pccase/create"
  get "build_items/create"
  get "cases/index"
  get "cases/show"
  get "memories/index"
  get "memories/show"
  get "psus/index"
  get "psus/show"
  get "coolers/index"
  get "coolers/show"
  get "storages/index"
  get "storages/show"
  get "motherboards/index"
  get "motherboards/show"
  get "gpus/index"
  get "gpus/show"
  get "cpus/index"
  get "cpus/show"
  get "builds/index"
  get "builds/show"
  get "builds/new"
  get "builds/create"
  get "parts/index"
  get "parts/show"
  get "users/index"
  get "users/show"
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
  
  # Authentication routes
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users, only: [:index, :show, :new, :create]
  resources :parts, only: [:index, :show]
  
  resources :builds do
    member do
      post :share
      get :shared
    end
    resources :build_items, only: [:create]
  end
  
  resources :cpus, only: [:index, :show]
  resources :gpus, only: [:index, :show]
  resources :motherboards, only: [:index, :show]
  resources :memories, only: [:index, :show]
  resources :storages, only: [:index, :show]
  resources :coolers, only: [:index, :show]
  resources :pc_cases, only: [:index, :show]
  resources :psus, only: [:index, :show]

end
