class AddTokenHashToChatWidgets < ActiveRecord::Migration[8.0]
  def change
    add_column :chat_widgets, :token_hash, :string
    add_index  :chat_widgets, :token_hash, unique: true
  end
end
