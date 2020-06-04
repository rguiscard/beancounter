class Balance < ApplicationRecord
  belongs_to :account, inverse_of: :balances
end
