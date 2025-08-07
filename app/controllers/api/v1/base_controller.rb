module Api
  module V1
    class BaseController < ActionController::Base
      include Pagy::Backend

      skip_before_action :verify_authenticity_token

      layout false
    end
  end
end
