class AddLeaderToBoard < ActiveRecord::Migration[6.1]
  def change
    add_reference :boards, :leader,  foreign_key: { to_table: :users }
  end
end
