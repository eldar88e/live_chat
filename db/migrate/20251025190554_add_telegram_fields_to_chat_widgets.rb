class AddTelegramFieldsToChatWidgets < ActiveRecord::Migration[8.0]
  def change
    add_column :chat_widgets, :tg_id, :bigint
    add_column :chat_widgets, :tg_token, :string
  end
end
