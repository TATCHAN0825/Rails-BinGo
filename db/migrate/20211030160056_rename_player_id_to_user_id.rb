class RenamePlayerIdToUserId < ActiveRecord::Migration[6.1]
  def change
    remove_reference :cards, :player, index: true
    add_reference :cards, :user, index: true
  end
end
