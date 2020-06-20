class CreateTrends < ActiveRecord::Migration[6.0]
  def change
    create_table :trends do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.text :data
      t.string :name

      t.timestamps
    end
  end
end
