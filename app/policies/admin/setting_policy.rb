module Admin
  class SettingPolicy < Admin::BasePolicy
    def index?
      user.root?
    end

    def create?
      user.root?
    end

    def update?
      user.root?
    end

    def destroy?
      user.root? || user.admin? || user.moderator?
    end
  end
end
