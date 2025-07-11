Rails.application.routes.draw do
  root "home#index"

  resource :session
  resource :registration, only: %i[new create]
  resource :user, only: %i[edit update] do
    get "confirm"
    post "reconfirm"
  end
  resources :passwords, param: :token

  resources :teams do
    resources :seats
    resources :pending_seats
    resources :statuses do
      post "draft"
    end
  end

  get "/dashboard/user", to: "dashboard#user"
  get "/dashboard", to: "dashboard#index"
  get "/dashboard/:team_id", to: "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :slack do
    get "create_team", to: "slack_installations#create"

    namespace :commands do
      post "simple_team", to: "simple_team#index"
    end
  end
end
