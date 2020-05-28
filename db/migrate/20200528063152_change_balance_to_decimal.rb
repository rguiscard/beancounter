class ChangeBalanceToDecimal < ActiveRecord::Migration[6.0]
  def up
    change_column :balances, :amount, :decimal, precision: 12, scale: 2, default: 0.0
  end

  def down
    change_column :balances, :amount, :integer, default: 0
  end
end
