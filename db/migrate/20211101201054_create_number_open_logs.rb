class CreateNumberOpenLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :number_open_logs do |t|
      t.references :number, null: false, foreign_key: true

      t.timestamps
    end
  end
end
