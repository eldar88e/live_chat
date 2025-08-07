module Api
  module V1
    class ChatsController < BaseController
      def show
        chat = Chat.find(params[:id])
        render json: chat.messages.order(:created_at)
      end

      def create
        chat = Chat.find_by(external_id: params[:external_id])

        if chat.blank?
          chat = Chat.create!(external_id: params[:external_id])
          reply_content = BotResponder.first_reply
          chat.messages.create!(role: :bot, content: reply_content)
        end

        render json: { chat_id: chat.id }
      end
    end
  end
end
