class AddNicknameToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :nickname, :string
  end
end
