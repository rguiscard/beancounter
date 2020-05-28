class AddUserToEntry < ActiveRecord::Migration[6.0]
  def change
    add_reference :entries, :user, null: false, foreign_key: {on_delete: :cascade}
    add_reference :accounts, :user, null: false, foreign_key: {on_delete: :cascade}
  end
end
