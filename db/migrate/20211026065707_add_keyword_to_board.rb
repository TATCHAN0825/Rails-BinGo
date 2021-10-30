class AddKeywordToBoard < ActiveRecord::Migration[6.1]
  def change
    add_column :boards, :keyword, :string
  end
end
