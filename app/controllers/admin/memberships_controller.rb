module Admin
  class MembershipsController < BaseController
    skip_before_action :set_resource, only: :create

    def create
      user = User.find_by(email: params[:email]&.strip&.downcase)
      return error_notice('Пользователь с таким email не найден') if user.nil?

      set_chat_widget
      membership = @chat_widget.memberships.build(user: user)
      authorize [:admin, membership]

      if membership.save
        render turbo_stream: turbo_stream.append(
          :members_list,
          partial: 'admin/memberships/membership',
          locals: { membership: membership }
        )
      else
        error_notice(membership.errors.full_messages)
      end
    end

    private

    def set_chat_widget
      @chat_widget = ChatWidget.find(params[:chat_widget_id])
    end
  end
end
