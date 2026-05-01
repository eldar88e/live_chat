module Api
  class BaseController < ApplicationController
    include Pagy::Method

    skip_before_action :verify_authenticity_token
    before_action :authenticate_chat_widget!

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    layout false

    attr_reader :current_chat_widget

    private

    def authenticate_chat_widget!
      token  = request.authorization&.sub(/^Bearer\s+/, '')
      domain = params[:domain] || request.headers['X-Widget-Domain']
      return head :unauthorized if token_domain_blank?(token, domain)

      # @current_chat_widget = ChatWidget.find_by(domain: normalize_domain(domain))
      # head :unauthorized unless @current_chat_widget&.valid_token?(token)
      @current_chat_widget = ChatWidget.find_with_token(token)
      head :unauthorized unless @current_chat_widget&.domain == normalize_domain(domain)
    rescue ActiveRecord::RecordNotFound
      head :unauthorized
    end

    def token_domain_blank?(token, domain)
      token.blank? || domain.blank?
    end

    def normalize_domain(value)
      value.to_s.strip.downcase.sub(%r{\Ahttps?://}, '').delete_suffix('/')
    end

    def not_found
      render json: { error: 'Not found' }, status: :not_found
    end
  end
end
