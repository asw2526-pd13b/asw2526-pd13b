Rails.application.routes.draw do
  resources :communities do
    post   :subscribe,   on: :member
    delete :unsubscribe, on: :member
  end
  resources :users
  resources :posts do
    resources :comments, only: [:create]   # /posts/:post_id/comments
  end
  resources :comments, only: [:destroy]
  root "posts#index"
end