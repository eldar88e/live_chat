class AddUniqueIndexToMemberships < ActiveRecord::Migration[8.1]
  def change
    add_index :memberships, %i[chat_widget_id user_id], unique: true
    change_column_default :memberships, :role, from: nil, to: 0
  end
end
