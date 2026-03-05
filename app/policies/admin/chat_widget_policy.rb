module Admin
  class ChatWidgetPolicy < Admin::BasePolicy
    def index?
      true
    end

    def create?
      true # TODO: ограничит добавление по тарифам
    end

    def update?
      chat_widget_owner? || user.root?
    end

    def destroy?
      chat_widget_owner? || user.root?
    end

    private

    def chat_widget_owner?
      record.owner_id == user.id
    end

    def chat_widget_member?
      record.users.include?(user)
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        if user.root?
          scope.all
        else
          scope.where(id: user.owned_chat_widgets.ids + user.chat_widgets.ids)
        end
      end
    end
  end
end
