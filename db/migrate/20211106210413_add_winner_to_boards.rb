class AddWinnerToBoards < ActiveRecord::Migration[6.1]
  def change
    add_reference :boards, :winner, foreign_key: { to_table: :users }
  end
end
