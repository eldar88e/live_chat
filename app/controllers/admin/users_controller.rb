module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]

    def index
      @q_users      = User.order(created_at: :desc).ransack(params[:q])
      @pagy, @users = pagy(@q_users.result)
    end

    def show
      @q_orders      = @user.orders.order(created_at: :desc).ransack(params[:q])
      @pagy, @orders = pagy(@q_orders.result)
    end

    def edit
      render turbo_stream: [
        turbo_stream.update(:modal_title, 'Редактирование пользователя'),
        turbo_stream.update(:modal_body, partial: '/admin/users/edit')
      ]
    end

    def update
      if @user.update(user_params)
        update_bonus
        render turbo_stream: [
          turbo_stream.replace(@user, partial: '/admin/users/user', locals: { user: @user }),
          success_notice(t('controller.users.update'))
        ]
      else
        error_notice(@user.errors.to_a)
      end
    end

    def destroy
      @user.destroy!
      redirect_to admin_users_path, status: :see_other, notice: t('controller.users.destroy')
    end

    private

    def update_bonus
      bonus_balance = { source: current_user, bonus_amount: params[:user][:bonus_balance], reason: :admin }
      return if params[:user][:bonus_balance].blank? || params[:user][:bonus_balance] == '0'

      @user.bonus_logs.create!(bonus_balance)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(setting: %i[email])
    end
  end
end
