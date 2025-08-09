module Api
  module V1
    class MessagesController < BaseController
      def index
        chat = Chat.find(params[:chat_id])
        pagy, messages = pagy(chat.messages.order(created_at: :desc).select(:content, :role, :created_at), limit: 50)

        render json: { messages: messages.reverse, meta: { total_pages: pagy.pages } }
      end

      def create
        chat = Chat.find(params[:chat_id])
        message = chat.messages.build(role: :client, content: params[:content])
        return if message.save

        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
