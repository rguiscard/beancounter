class AddBeancountUpdatedAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :beancount_updated_at, :datetime
  end
end
