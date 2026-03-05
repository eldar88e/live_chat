namespace :admin do
  root to: 'messages#index'

  resources :errors

  resources :messages, except: :show
  resources :settings, except: :show
  resources :users
  resources :chat_widgets
  resources :chats, only: :destroy
end
