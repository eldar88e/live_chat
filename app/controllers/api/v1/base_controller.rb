module Api
  module V1
    class BaseController < ActionController::Base
      include Pagy::Backend

      skip_before_action :verify_authenticity_token
      before_action :authenticate_chat_widget!

      layout false

      attr_reader :current_chat_widget

      private

      def authenticate_chat_widget!
        token  = request.authorization&.sub(/^Bearer\s+/, '')
        domain = params[:domain] || request.headers['X-Widget-Domain']
        return head :unauthorized if token.blank? || domain.blank?

        @current_chat_widget = ChatWidget.find_by(domain: normalize_domain(domain))
        head :unauthorized unless @current_chat_widget&.valid_token?(token)
      end

      def normalize_domain(value)
        value.to_s.strip.downcase.sub(%r{\Ahttps?://}, '').delete_suffix('/')
      end
    end
  end
end
