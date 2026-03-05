class AddProductionIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :chats, %i[chat_widget_id external_id], unique: true
    add_index :messages, %i[chat_id created_at]
  end
end
