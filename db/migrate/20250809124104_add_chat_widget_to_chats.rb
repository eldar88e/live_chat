class AddChatWidgetToChats < ActiveRecord::Migration[8.0]
  def change
    add_reference :chats, :chat_widget, null: false, foreign_key: true
  end
end
