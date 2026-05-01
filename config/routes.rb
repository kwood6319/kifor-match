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

  namespace :admin do
    resource :dashboard, only: [:show]
  end

  namespace :charity do
    resource :dashboard, only: [:show]
  end

  namespace :donor do
    resource :dashboard, only: [:show]
  end

  resources :requests do
    resources :offers, only: [ :index, :new, :create ]
    member do
      patch :activate
      patch :deactivate
    end
  end

  resources :offers, only: [ :show, :edit, :update, :destroy ] do
    collection do
      get :search
    end
    member do
      patch :approve
      patch :reject
      patch :mark_received
      patch :mark_as_shipped
      patch :accept
      patch :mark_sent

      patch :activate
      patch :deactivate
    end
  end

  resources :charities, only: [:index, :destroy] do
    member do
      patch :approve
      patch :activate
      patch :deactivate
    end
  end

  resources :donors, only: [:index, :destroy] do
    member do
      patch :activate
      patch :deactivate
    end
  end
end
