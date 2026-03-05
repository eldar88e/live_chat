namespace :admin do
  root to: 'messages#index'

  resources :errors

  resources :messages, except: %i[show destroy]
  resources :settings, except: :show
  resources :users
  resources :chat_widgets do
    resources :memberships, only: %i[create destroy]
  end
  resources :chats, only: :destroy
end
