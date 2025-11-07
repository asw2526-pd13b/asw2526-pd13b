Rails.application.routes.draw do
  resources :communities do
    post   :subscribe,   on: :member
    delete :unsubscribe, on: :member
  end
  resources :users
  resources :posts
  root "posts#index"
end