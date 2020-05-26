class Entry < ApplicationRecord
  enum directive: [:txn, :commodity, :balance, :pad, :note, :document, :price, :event, :query, :custom]
end
