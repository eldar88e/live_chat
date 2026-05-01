module Admin
  class BaseController < ApplicationController
    include Pagy::Method
    include ResourceConcerns

    before_action :authenticate_user!

    layout 'admin'

    private

    def render_not_found
      render template: '/pwa/not_found', status: :not_found, formats: :html, content_type: 'text/html'
    end
  end
end
