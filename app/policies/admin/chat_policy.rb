module Admin
  class ChatPolicy < Admin::BasePolicy
    def destroy?
      chat_widget_owner? || user.admin? || user.moderator?
    end

    private

    def chat_widget_owner?
      record.chat_widget.owner_id == user.id
    end
  end
end
