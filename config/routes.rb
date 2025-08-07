Rails.application.routes.draw do
  devise_for :users
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker

  root 'admin/messages#index'

  draw :api_v1
  draw :admin

  match '*unmatched', to: 'pwa#not_found', via: :all,
        constraints: ->(req) { !req.path.start_with?('/rails/active_storage') }
end
