require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  
  # API versioning
  namespace :api do
    namespace :v1 do
      resources :products
      
      get '/cart', to: 'carts#show'
      post '/cart', to: 'carts#create'
      post '/cart/add_item', to: 'carts#add_item'
      put '/cart/:product_id', to: 'carts#update_item'
      delete '/cart/:product_id', to: 'carts#remove_item'
      delete '/cart', to: 'carts#clear'
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
  root "rails/health#show"
end
