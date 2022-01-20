Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'login_test', to: 'sessions#test'
  resources :payments
  resources :users, only: [:show, :create, :update, :destroy]
end
