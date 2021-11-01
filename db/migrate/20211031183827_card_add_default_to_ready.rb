class CardAddDefaultToReady < ActiveRecord::Migration[6.1]
  def change
    change_column_default :cards, :ready, from: nil, to: false
  end
end
