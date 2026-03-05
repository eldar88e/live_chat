module Admin
  class MessagePolicy < Admin::BasePolicy
    def index?
      user.root? || chat_widget_owner? || chat_widget_member?
    end

    def create?
      user.root? || chat_widget_owner? || chat_widget_member?
    end

    def destroy?
      user.root? || chat_widget_owner?
    end

    private

    def chat_widget_owner?
      record.chat.chat_widget.owner_id == user.id
    end

    def chat_widget_member?
      record.chat.chat_widget.users.include?(user)
    end
  end
end
