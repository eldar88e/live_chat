Rails.application.routes.draw do
  root 'pages#home'

  devise_for :users, skip: [:registrations]
  get 'up' => 'rails/health#show', as: :rails_health_check

  authenticate :user, ->(user) { user.root? } do
    mount SolidQueueDashboard::Engine, at: "/admin/solid-queue"
    # mount PgHero::Engine, at: '/admin/pghero'
  end

  resource :widget, only: [:show]

  draw :api_v1
  draw :admin

  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'offline' => 'pwa#offline', as: :pwa_offline

  match '*unmatched', to: 'pwa#not_found', via: :all,
        constraints: ->(req) { !req.path.start_with?('/rails/active_storage') }
end
