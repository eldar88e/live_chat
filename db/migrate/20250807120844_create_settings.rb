class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.string :variable, null: false
      t.string :value
      t.string :description

      t.timestamps
    end

    add_index :settings, :variable, unique: true
  end
end
