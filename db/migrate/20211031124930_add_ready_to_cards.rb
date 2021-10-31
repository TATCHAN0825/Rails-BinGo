class AddReadyToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :ready, :boolean
  end
end
