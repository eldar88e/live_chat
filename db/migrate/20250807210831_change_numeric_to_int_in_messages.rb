class ChangeNumericToIntInMessages < ActiveRecord::Migration[8.0]
  def change
    change_column :messages, :role, :integer
  end
end
