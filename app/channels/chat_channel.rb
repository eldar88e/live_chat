class ChatChannel < ApplicationCable::Channel
  def subscribed
    widget = find_widget
    return reject unless widget

    @chat = widget.chats.find_by(external_id: params[:external_id])
    return reject unless @chat

    stream_from "chat_#{@chat.id}"
    # rubocop:disable Rails/SkipsModelValidations
    @chat.update_column(:online, true)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def unsubscribed
    # rubocop:disable Rails/SkipsModelValidations
    @chat&.update_column(:online, false)
    # rubocop:enable Rails/SkipsModelValidations
  end

  private

  def find_widget
    token = params[:token]
    return nil if token.blank?

    ChatWidget.find_with_token(token)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
