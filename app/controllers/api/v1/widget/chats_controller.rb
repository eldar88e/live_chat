module Api
  module V1
    module Widget
      class ChatsController < BaseController
        def show
          pagy, messages = pagy(chat.messages.order(created_at: :desc).select(:content, :role, :created_at), limit: 50)
          render json: { messages: messages.reverse, meta: { total_pages: pagy.pages } }
        end

        def create
          chat = current_chat_widget.chats.find_by(external_id: params[:external_id])

          if chat.blank?
            utm = params.permit(
              utm: %i[utm_source utm_medium utm_campaign utm_term utm_content]
            )[:utm] || {}
            chat = current_chat_widget.chats.create!(external_id: params[:external_id], utm: utm)
            reply_content = BotResponder.first_reply
            chat.messages.create!(role: :bot, content: reply_content)
          end

          render json: { chat_id: chat.id }
        end
      end
    end
  end
end
