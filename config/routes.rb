Rails.application.routes.draw do
  resources :communities
  resources :users
  resources :posts
  root "posts#index"
end