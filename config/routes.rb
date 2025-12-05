Rails.application.routes.draw do

  devise_for :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      sessions: 'devise/sessions'
    },
    skip: [:registrations, :passwords, :confirmations]


  devise_scope :user do
    delete '/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  post "/vote/:type/:id/:value", to: "votes#vote", as: :vote

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :update]
      resources :communities do
        post :subscribe, on: :member
        delete :unsubscribe, on: :member
      end
      resources :posts do
        resources :comments, only: [:index, :create]
        resource :vote, only: [:create, :update, :destroy], controller: 'post_votes'
      end
      resources :comments, only: [:destroy] do
        resource :vote, only: [:create, :update, :destroy], controller: 'comment_votes'
      end
      #resources :votes, only: [:create]
    end
  end

  resources :communities do
    post   :subscribe,   on: :member
    delete :unsubscribe, on: :member
  end

  resources :users, only: [:index, :show, :edit, :update] do
    member do
      post :regenerate_api_key
    end
  end

  resources :posts do
    resources :comments, only: [:create]  # crear comentario asociado a post
  end

  resources :comments, only: [:destroy]

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
