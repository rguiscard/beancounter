class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.datetime :date, null: false
      t.integer :directive, null: false, default: 0
      t.string :name, null: false
      t.string :currencies, array: true, null: false, default: []
      t.string :booking

      t.timestamps
    end
 
    add_index :accounts, :currencies, using: 'gin'
  end
end
