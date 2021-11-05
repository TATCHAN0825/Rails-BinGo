class AddCurrentToBoards < ActiveRecord::Migration[6.1]
  def change
    add_reference :boards, :current, null: true, foreign_key: { to_table: :users }
  end
end
