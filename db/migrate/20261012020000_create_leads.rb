class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.references :chat_widget, null: false, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.timestamps
    end

    add_index :leads, %i[chat_widget_id phone], unique: true
    add_index :leads, %i[chat_widget_id email], unique: true
    add_reference :chats, :lead, foreign_key: true
  end
end
