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
            chat          = create_new_chat_widget
            reply_content = BotResponder.first_reply
            chat.messages.create!(role: :bot, content: reply_content)
          end

          Rails.logger.info(
            'NEW CHAT DEBUG: ' \
            "id=#{chat.id}, " \
            "lead_id_method=#{chat.respond_to?(:lead_id)}, " \
            "has_attribute=#{chat.has_attribute?(:lead_id)}, " \
            "attributes=#{chat.attributes.keys.inspect}"
          )

          render json: chat_metadata(chat)
        end

        private

        def chat_metadata(chat)
          {
            chat_id: chat.id,
            contact_token: chat.signed_id(purpose: :contacts, expires_in: 24.hours),
            contacts_saved: chat.lead_id.present?,
            has_client_messages: chat.messages.client.exists?
          }
        end

        def create_new_chat_widget
          utm = params.permit(utm: %i[utm_source utm_medium utm_campaign utm_term utm_content])[:utm] || {}
          current_chat_widget.chats.create!(external_id: params[:external_id], utm: utm)
        end
      end
    end
  end
end
