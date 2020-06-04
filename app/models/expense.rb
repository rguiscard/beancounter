class Expense < ApplicationRecord
  belongs_to :user, inverse_of: :expenses
end
