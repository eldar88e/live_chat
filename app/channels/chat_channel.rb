class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = Chat.find(params[:chat_id])
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
end
