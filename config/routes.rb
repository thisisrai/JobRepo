Rails.application.routes.draw do
  resources :jobs
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :users, only: [:create]
  post "/login", to: "users#login"
  get "/auto_login", to: "users#auto_login"
  get "/healthcheck", to: "healthcheck#check"
end
