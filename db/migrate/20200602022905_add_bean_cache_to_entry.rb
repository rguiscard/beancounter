class AddBeanCacheToEntry < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :bean_cache, :text
    add_column :postings, :bean_cache, :text
  end
end
