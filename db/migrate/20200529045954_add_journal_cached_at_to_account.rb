class AddJournalCachedAtToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :journal_cached_at, :datetime
  end
end
