module Admin
  class LeadPolicy < BasePolicy
    def index?
      true
    end

    def destroy?
      chat_widget_owner? || user.root?
    end

    private

    def chat_widget_owner?
      record.chat_widget.owner_id == user.id
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        widgets = ChatWidgetPolicy::Scope.new(user, ChatWidget).resolve
        scope.where(chat_widget_id: widgets.select(:id))
      end
    end
  end
end
