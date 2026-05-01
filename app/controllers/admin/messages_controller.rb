module Admin
  class MessagesController < BaseController
    skip_before_action :authorize_user!, only: :index
    before_action :set_chats, :set_chats_page, only: :index
    before_action :set_resource, :authorize_user!, only: :create

    def index
      @chats_page, @chats = pagy(@chats, limit: 30, page_key: 'chats_page')
      @current_chat       = authorized_chats.find_by(id: params[:chat_id]) || @chats.first
      messages            = @current_chat&.messages&.order(created_at: :desc) || Message.none
      @pagy, @messages    = pagy(messages, limit: 50)
      @messages           = @messages.reverse
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
      # rubocop:disable Layout/IndentationWidth
      # rubocop:disable Layout/ElseAlignment
      @authorized_chats ||= if current_user.root?
        Chat.all
      else
        # Chat.joins(:chat_widget)
        #     .left_joins(chat_widget: :memberships)
        #     .where('chat_widgets.owner_id = :uid OR memberships.user_id = :uid', uid: current_user.id)
        #     .distinct
        Chat.where(
          chat_widget_id: ChatWidget.where(owner_id: current_user.id).or(
            ChatWidget.where(id: current_user.memberships.select(:chat_widget_id))
          )
        )
      end
      # rubocop:enable Layout/ElseAlignment
      # rubocop:enable Layout/IndentationWidth
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
