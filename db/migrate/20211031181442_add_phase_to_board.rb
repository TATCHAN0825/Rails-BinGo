class AddPhaseToBoard < ActiveRecord::Migration[6.1]
  def change
    add_column :boards, :phase, :integer, default: 0 # default: wait
  end
end
