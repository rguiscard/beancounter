class AddNicknameToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :nickname, :string
    add_column :accounts, :closed, :boolean, default: false
  end
end
