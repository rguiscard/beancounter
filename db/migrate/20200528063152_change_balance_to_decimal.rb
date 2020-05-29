class ChangeBalanceToDecimal < ActiveRecord::Migration[6.0]
  def up
    change_column :balances, :amount, :decimal, precision: 12, scale: 2, default: 0.0
    change_column :accounts, :journal, :text
  end

  def down
    change_column :balances, :amount, :integer, default: 0
    change_column :accounts, :journal, :binary
  end
end
