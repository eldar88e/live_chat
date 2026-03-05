module Admin
  class ChatPolicy < Admin::BasePolicy
    def index?
      chat_widget_owner? || chat_widget_member? || user.root?
    end

    def show?
      chat_widget_owner? || chat_widget_member? || user.root?
    end

    def create?
      chat_widget_owner? || user.root?
    end

    def update?
      chat_widget_owner? || user.root?
    end

    def destroy?
      chat_widget_owner? || user.root?
    end

    private

    def chat_widget_owner?
      record.chat_widget.owner_id == user.id
    end

    def chat_widget_member?
      record.chat_widget.users.exists?(user.id)
    end
  end
end
