class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :currencies, array: true, null: false, default: []

      t.timestamps
    end
 
    add_index :accounts, :currencies, using: 'gin'
  end
end
