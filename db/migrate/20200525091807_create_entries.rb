class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.datetime :date, null: false
      t.integer :directive, null: false, default: 0
      t.text :arguments

      t.timestamps
    end
  end
end
