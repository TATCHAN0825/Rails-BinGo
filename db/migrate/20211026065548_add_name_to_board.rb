class AddNameToBoard < ActiveRecord::Migration[6.1]
  def change
    add_column :boards, :name, :string
  end
end
