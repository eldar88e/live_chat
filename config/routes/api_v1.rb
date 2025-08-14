namespace :api do
  namespace :v1 do
    namespace :widget do
      resources :chats, only: %i[create show] do
        resources :messages, only: %i[index create]
      end
    end
  end
end
