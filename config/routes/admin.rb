namespace :admin do
  root to: 'messages#index'

  resources :messages
  resources :settings
  resources :users
  resources :errors
end
