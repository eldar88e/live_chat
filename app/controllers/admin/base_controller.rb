module Admin
  class BaseController < ActionController::Base
    include Pundit::Authorization
    include MainConcerns
    include Pagy::Backend

    before_action :authenticate_user!, :authorize_admin_access!

    layout 'admin'

    private

    def authorize_admin_access!
      authorize %i[admin base], :admin_access?
    end
  end
end
