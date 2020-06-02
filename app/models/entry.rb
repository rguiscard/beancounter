class Entry < ApplicationRecord
  enum directive: [:txn, :open, :close, :commodity, :balance, :pad, :note, :document, :price, :event, :query, :custom, :asterisk, :exclamation]

  belongs_to :user
  has_many :postings

  before_save { |entry| entry.bean_cache = entry.to_bean }

  scope :transactions, -> { where(directive: [:txn, :asterisk, :exclamation]) }

  def transaction?
    self.txn? || self.asterisk? || self.exclamation?
  end

  def to_bean
    words = [date.strftime('%Y-%m-%d')]

    if self.asterisk?
      words << "*"
    elsif self.exclamation?
      words << "!"
    else
      words << self.directive
    end

    words << self.arguments
    words.join(' ')
  end
end
