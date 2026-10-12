module Admin
  class LeadsController < BaseController
    def index
      @chat_widgets = policy_scope([:admin, ChatWidget]).order(:name, :id)
      leads = policy_scope([:admin, Lead]).for_widget(params[:chat_widget_id]).for_chat(params[:chat_id])
      @pagy, @leads = pagy(leads.order(:chat_widget_id, created_at: :desc, id: :desc)
                               .preload(:chat_widget, :chats), limit: 30)
    end
  end
end
