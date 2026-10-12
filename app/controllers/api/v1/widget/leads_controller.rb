module Api
  module V1
    module Widget
      class LeadsController < BaseController
        def create
          chat = contact_chat
          return head :unauthorized unless valid_contact_token?(chat)
          return head :unprocessable_content unless chat.messages.client.exists?

          CaptureLead.call(chat: chat, attributes: params.expect(contact: %i[name phone email]))
          head :no_content
        rescue CaptureLead::ContactConflict => e
          render json: { error: e.message }, status: :conflict
        rescue ActiveRecord::RecordInvalid
          render json: { error: 'Укажите имя и корректный телефон (от 7 до 15 цифр) или email.' },
                 status: :unprocessable_content
        end

        private

        def contact_chat
          current_chat_widget.chats.find(params.expect(:chat_id))
        end

        def valid_contact_token?(chat)
          Chat.find_signed(params[:contact_token], purpose: :contacts) == chat
        end
      end
    end
  end
end
