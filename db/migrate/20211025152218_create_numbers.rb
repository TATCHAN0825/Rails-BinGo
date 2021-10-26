class CreateNumbers < ActiveRecord::Migration[6.1]
  def change
    create_table :numbers do |t|
      t.references :card, null: false, foreign_key: true
      t.integer :value
      t.boolean :open, null: false, default: false
      t.integer :column, null: false
      t.integer :row, null: false

      t.timestamps
    end

    add_index :numbers, %i[id column row], unique: true
  end
end
