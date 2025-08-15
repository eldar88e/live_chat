module Admin
  class BaseController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    before_action :authenticate_user!, :authorize_admin_access!

    layout 'admin'

    private

    def authorize_admin_access!
      authorize %i[admin base], :admin_access?
    end
  end
end
