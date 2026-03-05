module Admin
  class MessagePolicy < Admin::BasePolicy
    def index?
      true
    end

    def create?
      user.root? || chat_widget_owner? || chat_widget_member?
    end

    def destroy?
      user.root? || chat_widget_owner?
    end

    private

    def chat_widget
      @chat_widget ||= record.chat.chat_widget
    end

    def chat_widget_owner?
      chat_widget.owner_id == user.id
    end

    def chat_widget_member?
      chat_widget.users.exists?(user.id)
    end
  end
end
