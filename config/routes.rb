Rails.application.routes.draw do
  resources :jobs
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :users, only: [:create]
  post "/login", to: "users#login"
  get "/auto_login", to: "users#auto_login"
  get "/healthcheck", to: "healthcheck#check"

  # Route for requesting a password reset link
  post 'password_resets', to: 'password_resets#create'

  # Route for resetting the password using the token
  put 'password_resets/:token', to: 'password_resets#update', as: 'password_reset'

  # Route for stories
  get '/stories', to: "stories#index"
  post '/stories', to: "stories#create"
end
