class AdminChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = Chat.find(params[:chat_id])
    return reject unless @chat

    stream_from "admin_chat_#{@chat.id}"
    @chat.update!(online: true)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
