namespace :admin do
  get '/', to: 'dashboard#index'
  get '/dashboard/show', to: 'dashboard#show' # TODO: temp route
  resources :products do
    resources :photos, only: %i[create destroy]
  end
  resources :settings
  resources :orders
  resources :users
  resources :mailings
  resources :analytics, only: :index
  resources :messages, only: %i[index new create destroy]
  resources :supports, only: %i[index new create edit update destroy]
  resources :new_messages
  resources :reviews
  resources :product_subscriptions, only: %i[index destroy]
  resources :bank_cards, only: %i[index new create edit update]
  resources :attachments, only: %i[destroy]
  resources :answers, only: :index
  resources :errors, only: %i[index show]
end
