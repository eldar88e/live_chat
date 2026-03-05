module Admin
  class UsersController < BaseController
    def index
      @q_users          = User.order(created_at: :desc).ransack(params[:q])
      @pagy, @resources = pagy(@q_users.result)
    end

    private

    def user_params
      params.expect(user: %i[email password password_confirmation role])
    end
  end
end
