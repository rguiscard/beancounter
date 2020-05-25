class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.datetime :date, null: false
      t.string :directive, null: false, default: "*"
      t.text :arguments

      t.timestamps
    end
  end
end
