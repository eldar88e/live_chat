class AddUtmToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :utm, :jsonb, default: {}, null: false
  end
end
