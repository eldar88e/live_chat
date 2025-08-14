class WidgetsController < ApplicationController
  before_action :set_web_widget
  after_action :allow_iframe_requests
  layout false

  private

  def set_web_widget
    @web_widget = ChatWidget.find_by_token(params[:token])
    raise ActiveRecord::RecordNotFound if @web_widget.blank?
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error('web widget does not exist')
    render json: { error: 'web widget does not exist' }, status: :not_found
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
