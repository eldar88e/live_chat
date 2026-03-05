module Admin
  class BaseController < ApplicationController
    include Pundit::Authorization
    include Pagy::Method
    include ResourceConcerns

    before_action :authenticate_user!, :authorize_user!

    layout 'admin'

    private

    def authorize_user!
      authorize [:admin, @resource || resource_class]
    end
  end
end
