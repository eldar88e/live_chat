module Admin
  class MessagesController < BaseController
    skip_before_action :authorize_user!, only: :index
    before_action :set_chats, :set_chats_page, only: :index
    before_action :set_resource, :authorize_user!, only: :create

    def index
      @pages, @chats   = pagy(@chats, limit: 20, page_key: :chats_page)
      @current_chat    = authorized_chats.find_by(id: params[:chat_id]) || @chats.first
      messages         = @current_chat&.messages&.order(created_at: :desc) || Message.none
      @pagy, @messages = pagy(messages, limit: 50)
      @messages        = @messages.reverse
    end

    def create
      if @resource.save
        render turbo_stream: success_notice('Сообщение отправлено.')
      else
        error_notice(@resource.errors.to_a)
      end
    end

    private

    def set_chats
      @chats = authorized_chats.joins(:messages)
                               .select('chats.*, MAX(messages.created_at)')
                               .group('chats.id')
                               .order('MAX(messages.created_at) DESC')
                               .preload(:chat_widget)
    end

    def authorized_chats
      return Chat.all if current_user.root?

      Chat.joins(:chat_widget)
          .left_joins(chat_widget: :memberships)
          .where('chat_widgets.owner_id = :uid OR memberships.user_id = :uid', uid: current_user.id)
          .distinct
    end

    def set_chats_page
      params[:chats_page] ||= session[:chats_page] || 1
      session[:chats_page] = params[:chats_page]
    end

    def set_resource
      chat      = Chat.find(params[:chat_id])
      @resource = chat.messages.build(role: :manager, content: params[:content])
    end
  end
end
