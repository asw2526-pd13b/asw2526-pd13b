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
      resources :communities do
        member do
          post :subscribe
          delete :unsubscribe
        end
      end

      resources :posts do
        resources :comments, only: [:create]
      end

      resources :comments, only: [:update, :destroy]
    end
  end

  resources :communities do
    post   :subscribe,   on: :member
    delete :unsubscribe, on: :member
  end

  resources :users, only: [:index, :show, :edit, :update]

  resources :posts do
    resources :comments, only: [:create]  # crear comentario asociado a post
  end

  resources :comments, only: [:destroy]

  resources :users, only: [:index, :show, :edit, :update] do
    member do
      post :regenerate_api_key
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end