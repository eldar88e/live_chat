class CreateChatWidgets < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_widgets do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string  :name, null: false
      t.string  :domain, null: false
      t.string  :token_digest, null: false
      t.jsonb   :settings, null: false, default: {}
      t.timestamps
    end
    add_index :chat_widgets, :domain, unique: true
  end
end
