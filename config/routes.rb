Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               omniauth_callbacks: "users/omniauth_callbacks",
               sessions: "devise/sessions"
             },
             skip: [:registrations, :passwords, :confirmations]

  devise_scope :user do
    delete "/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  resources :communities do
    member do
      post :subscribe
      delete :unsubscribe
    end
  end

  resources :users, only: [:index, :show, :edit, :update]

  resources :posts do
    resources :comments, only: [:create]
  end

  resources :comments, only: [:destroy]

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
