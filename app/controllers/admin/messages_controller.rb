module Admin
  class MessagesController < BaseController
    skip_before_action :set_resource
    before_action :set_chats, :set_chats_page, only: :index

    def index
      @pages, @chats   = pagy(@chats, limit: 20, page_key: :chats_page)
      @current_chat    = Chat.find_by(id: params[:chat_id]) || @chats.first
      messages         = @current_chat&.messages&.order(created_at: :desc) || Message.none
      @pagy, @messages = pagy(messages, limit: 50)
      @messages        = @messages.reverse
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

    private

    def set_chats
      @chats = authorized_chats.joins(:messages)
                               .select('chats.*, MAX(messages.created_at)')
                               .group('chats.id')
                               .order('MAX(messages.created_at) DESC')
                               .includes(:chat_widget)
    end

    def authorized_chats
      return Chat.all if current_user.root?

      chat_widget_ids = current_user.owned_chat_widgets.ids + current_user.chat_widgets.ids
      Chat.joins(:chat_widget).where(chat_widgets: { id: chat_widget_ids })
    end

    def set_chats_page
      params[:chats_page] ||= session[:chats_page] || 1
      session[:chats_page] = params[:chats_page]
    end
  end
end
