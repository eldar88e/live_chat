module Admin
  class ChatsController < BaseController
    before_action :set_chat, :authorize_message, only: :destroy

    def destroy
      @chat.destroy!
      redirect_to admin_messages_path, status: :see_other, notice: t('.destroy')
    end

    private

    def set_chat
      @chat = Chat.find(params[:id])
    end

    def authorize_message
      authorize [:admin, @chat]
    end
  end
end
