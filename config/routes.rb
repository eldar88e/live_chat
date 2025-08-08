Rails.application.routes.draw do
  root 'admin/messages#index'

  devise_for :users
  get 'up' => 'rails/health#show', as: :rails_health_check

  mount SolidQueueDashboard::Engine, at: "/solid-queue"

  draw :api_v1
  draw :admin

  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker

  match '*unmatched', to: 'pwa#not_found', via: :all,
        constraints: ->(req) { !req.path.start_with?('/rails/active_storage') }
end
