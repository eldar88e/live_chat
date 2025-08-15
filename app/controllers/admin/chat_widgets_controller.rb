module Admin
  class ChatWidgetsController < BaseController
    before_action :set_chat_widget, only: %i[edit update destroy]

    def index
      if current_user.admin?
        @chat_widgets = ChatWidget.all
      else
        @chat_widgets = current_user.owned_chat_widgets
        @chat_widgets_shared = current_user.chat_widgets
      end
    end

    def new
      @chat_widget = ChatWidget.new
      render turbo_stream: [
        turbo_stream.update(:modal_title, 'Добавить виджет'),
        turbo_stream.update(:modal_body, partial: '/admin/chat_widgets/form', locals: { method: :post })
      ]
    end

    def edit
      render turbo_stream: [
        turbo_stream.update(:modal_title, 'Редактировать виджет'),
        turbo_stream.update(:modal_body, partial: '/admin/chat_widgets/form', locals: { method: :patch })
      ]
    end

    def create
      @chat_widget = current_user.owned_chat_widgets.build(chat_widget_params)

      token = @chat_widget.rotate_token!
      if token
        # redirect_to admin_chat_widgets_path, notice: t('.create')
        show_token(token)
      else
        error_notice(@chat_widget.errors.to_a)
      end
    end

    def update
      if params[:token].present?
        token = @chat_widget.rotate_token!
        return show_token(token)
      end

      if @chat_widget.update(chat_widget_params)
        redirect_to admin_chat_widgets_path, notice: t('.update')
      else
        error_notice(@chat_widget.errors.to_a)
      end
    end

    def destroy
      @chat_widget.destroy!
      redirect_to admin_chat_widgets_path, status: :see_other, notice: t('.destroy')
    end

    private

    def show_token(token)
      render turbo_stream: [
        turbo_stream.update(:modal_title, 'Токен'),
        turbo_stream.update(:modal_body, html: "Токен: #{token}")
      ]
    end

    def set_chat_widget
      @chat_widget =
        if current_user.admin?
          ChatWidget.find(params[:id])
        else
          current_user.owned_chat_widgets.find(params[:id])
        end
    end

    def chat_widget_params
      params.expect(chat_widget: %i[name domain settings])
    end
  end
end
