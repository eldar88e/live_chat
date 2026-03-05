module Admin
  class ChatWidgetPolicy < Admin::BasePolicy
    def index?
      user.root? || chat_widget_owner? || chat_widget_member?
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
  end
end
