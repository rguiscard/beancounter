class CreateBalances < ActiveRecord::Migration[6.0]
  def change
    create_table :balances do |t|
      t.integer :amount, default: 0
      t.string :currency, null: false
      t.references :account, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
