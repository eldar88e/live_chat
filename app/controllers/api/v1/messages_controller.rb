class Api::MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    chat = Chat.find(params[:chat_id])
    render json: chat.messages.order(:created_at)
  end

  def create
    chat = Chat.find(params[:chat_id])
    message = chat.messages.create!(role: 'user', content: params[:content])

    reply_content = BotResponder.reply(message.content)
    chat.messages.create!(role: 'bot', content: reply_content)

    render json: chat.messages.order(:created_at)
  end
end
