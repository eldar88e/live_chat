module Admin
  class ChatsController < BaseController
    def destroy
      @resource.destroy!
      redirect_to admin_messages_path, status: :see_other, notice: t('.destroy')
    end
  end
end
