class AdminChatChannel < ApplicationCable::Channel
  def subscribed
    puts '*' * 10
    puts params
    puts '=' * 10
    @chat = Chat.find(params[:admin_chat_id])
    return reject unless @chat

    stream_from "admin_chat_#{@chat.id}"
    @chat.update!(online: true)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
