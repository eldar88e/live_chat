module Admin
  class UserPolicy < Admin::BasePolicy
    def index?
      user.root?
    end

    def show?
      user.root? || @record == user
    end

    def create?
      user.root?
    end

    def update?
      user.root? || @record == user
    end

    def destroy?
      user.root?
    end
  end
end
