Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :users
  resources :charity_profile do
    resources :request
    resources :offer, only: [ :index, :show, :edit, :update ]
  end
  resources :donor_profile do
    resources :request, only: [ :index, :show ]
    resources :offer, only: [ :index, :show, :edit, :update ]
  end

  #index (show all of a class)
  #show (show one of a class)
  #new (make a new instance of a class)
  #create (POST request for a new class)
  #edit (change an instance)
  #update (PATCH request for an instance)
  #destroy (destroy an instance of a class)


end
