class Entry < ApplicationRecord
  enum directive: [:txn, :open, :close, :commodity, :balance, :pad, :note, :document, :price, :event, :query, :custom]

  has_many :postings

  def to_bean
    words = [date.strftime('%Y-%m-%d')]
    words << self.directive
    words << self.arguments
    words.join(' ')
  end
end
