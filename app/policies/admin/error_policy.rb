module Admin
  class ErrorPolicy < Admin::BasePolicy
    def index?
      user.root?
    end

    def show?
      user.root?
    end
  end
end
