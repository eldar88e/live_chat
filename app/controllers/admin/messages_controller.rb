module Admin
  class MessagesController < BaseController
    before_action :authorize_message, only: :destroy

    def index
      @chats = Chat.joins(:messages)
                   .select('chats.*, MAX(messages.created_at) AS last_message_at')
                   .group('chats.id')
                   .order('last_message_at DESC')
      @current_chat = Chat.find_by(id: params[:chat_id]) || @chats.first
      messages = @current_chat&.messages&.order(created_at: :desc) || Message.none
      @pagy, @messages = pagy(messages, limit: 50)
      @messages = @messages.reverse
    end

    def create
      chat    = Chat.find(params[:chat_id])
      message = chat.messages.build(role: :manager, content: params[:content])

      if message.save
        render turbo_stream: success_notice('Сообщение отправлено.')
      else
        error_notice(message.errors.to_a)
      end
    end

    def destroy
      @message = Message.find(params[:id])
      @message.destroy!
      render turbo_stream: [turbo_stream.remove(@message), success_notice('Сообщение было успешно удалено.')]
    end

    private

    def authorize_message
      authorize [:admin, Message]
    end
  end
end
