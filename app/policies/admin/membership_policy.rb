module Admin
  class MembershipPolicy < Admin::BasePolicy
    def create?
      chat_widget_owner? || user.root?
    end

    def destroy?
      chat_widget_owner? || user.root?
    end

    private

    def chat_widget_owner?
      record.chat_widget.owner_id == user.id
    end
  end
end
