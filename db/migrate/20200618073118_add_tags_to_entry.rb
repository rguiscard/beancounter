class AddTagsToEntry < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :tags,  :text, array: true, default: []
    add_column :entries, :links, :text, array: true, default: []
    add_index  :entries, :tags,  using: :gin
    add_index  :entries, :links, using: :gin
  end
end
