Rails.application.routes.draw do
  # Devise per OAuth
  devise_for :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      sessions: 'devise/sessions'
    },
    skip: [:registrations, :passwords, :confirmations]

  # Ruta de logout explícita ABANS de resources :users
  devise_scope :user do
    delete '/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # Resources - users VA DESPRÉS
  resources :communities do
    post   :subscribe,   on: :member
    delete :unsubscribe, on: :member
  end

  resources :users, only: [:index, :show, :edit, :update]

  resources :posts do
    resources :comments, only: [:create]
  end

  resources :comments, only: [:destroy]

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end