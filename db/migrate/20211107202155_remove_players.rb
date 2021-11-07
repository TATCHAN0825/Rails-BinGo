class RemovePlayers < ActiveRecord::Migration[6.1]
  def change
    drop_table :players do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
