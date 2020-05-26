class CreatePostings < ActiveRecord::Migration[6.0]
  def change
    create_table :postings do |t|
      t.string :flag
      t.references :account, null: false, foreign_key: {on_delete: :cascade}
      t.text :arguments, null: false
      t.text :comment
      t.references :entry, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
