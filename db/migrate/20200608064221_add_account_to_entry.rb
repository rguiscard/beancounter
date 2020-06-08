class AddAccountToEntry < ActiveRecord::Migration[6.0]
  def change
    add_reference :entries, :account, foreign_key: {on_delete: :cascade}
  end
end
