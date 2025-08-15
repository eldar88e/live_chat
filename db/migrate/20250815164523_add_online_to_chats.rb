class AddOnlineToChats < ActiveRecord::Migration[8.0]
  def change
    add_column :chats, :online, :boolean, default: false, null: false
  end
end
