Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'current_login_status', to: 'sessions#show'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :payments
  resources :users, only: [:show, :create, :update, :destroy]
end
