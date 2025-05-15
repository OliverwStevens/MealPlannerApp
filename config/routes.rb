Rails.application.routes.draw do
  get "search/index"
  get "shopping_lists/index"
  get "meal_plans/index"
  get "meal_plans/new"
  get "meal_plans/create"
  get "meal_plans/destroy"
  resources :meals
  get "home/index"
  resources :recipes
  resources :pantry_items do
    collection do
      get :inventory
    end
  end
    resources :home
  resources :meal_plans, only: [ :index ] do
    collection do
      post :update_plan, action: :create_or_update
      post :auto_generate
      get :generate_from_pantry

      delete :clear_week
    end
  end

  resources :shopping_lists, only: [ :index ]
  get "/search", to: "search#index", as: :search
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  post "recipes/:id/add", to: "recipes#add", as: "add_recipe", constraints: { id: /\d+/ }
  post "meals/:id/add", to: "meals#add", as: "add_meal", constraints: { id: /\d+/ }

  get "home/:type/:id", to: "home#show", as: "home_show"

  # Defines the root path route ("/")
  root "home#index"
end
