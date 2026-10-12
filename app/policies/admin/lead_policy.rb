module Admin
  class LeadPolicy < BasePolicy
    def index?
      true
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        widgets = ChatWidgetPolicy::Scope.new(user, ChatWidget).resolve
        scope.where(chat_widget_id: widgets.select(:id))
      end
    end
  end
end
