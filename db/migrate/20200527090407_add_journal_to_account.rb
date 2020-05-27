class AddJournalToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :journal, :binary
  end
end
