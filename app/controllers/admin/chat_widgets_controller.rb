module Admin
  class ChatWidgetsController < BaseController
    def index
      @q_chat_widgets = policy_scope([:admin, resource_class]).order(created_at: :desc).ransack(params[:q])
      @pagy, @chat_widgets = pagy(@q_chat_widgets.result)
    end

    def create
      @chat_widget = current_user.owned_chat_widgets.build(chat_widget_params)
      token        = @chat_widget.rotate_token!
      if @chat_widget.save
        render_after_create(token)
      else
        error_notice(@chat_widget.errors.to_a)
      end
    end

    def update
      if params[:token].present?
        token = @resource.rotate_token!
        return render turbo_stream: show_token(token) if @resource.save
      end

      if @resource.update(chat_widget_params)
        redirect_to admin_chat_widgets_path, notice: t('.update')
      else
        error_notice @resource.errors.to_a
      end
    end

    private

    def show_token(token)
      h = ActionController::Base.helpers
      [
        turbo_stream.update(:modal_title, 'Токен'),
        turbo_stream.update(
          :modal_body,
          html: h.content_tag(:div, "Токен: #{token}", class: 'text-gray-900 dark:text-white')
        )
      ]
    end

    def render_after_create(token)
      render turbo_stream: [
        success_notice('Виджет был успешно создан.'),
        turbo_stream.append(
          :chat_widgets, partial: '/admin/chat_widgets/chat_widget', locals: { chat_widget: @chat_widget }
        )
      ] + show_token(token)
    end

    def chat_widget_params
      params.expect(chat_widget: %i[name domain settings tg_id tg_token])
    end
  end
end
