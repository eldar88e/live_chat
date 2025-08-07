class Api::ChatsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    chat = Chat.find_or_create_by(external_id: params[:external_id])
    render json: { chat_id: chat.id }
  end

  def show
    chat = Chat.find(params[:id])
    render json: chat.messages.order(:created_at)
  end
end
