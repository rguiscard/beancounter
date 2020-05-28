class AddBeancountToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :beancount, :binary
  end
end
