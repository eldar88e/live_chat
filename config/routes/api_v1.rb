namespace :api do
  namespace :v1 do
    resources :chats, only: [:create, :show] do
      resources :messages, only: [:index, :create]
    end
  end
end
