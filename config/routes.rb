Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy"

  get "oauth/authorize" => "oauth#authorize"
  get "oauth/callback" => "oauth#callback"

  resources :user_images, only: [:new, :create, :index]
  post "user_images/tweet" => "user_images#tweet"
  # Defines the root path route ("/")
  # root "posts#index"
end
