class Entry < ApplicationRecord
  enum directive: [:txn, :open, :close, :commodity, :balance, :pad, :note, :document, :price, :event, :query, :custom, :asterisk, :exclamation]

  belongs_to :user
  has_many :postings

  before_save do |entry|
    postings = entry.postings.pluck(:bean_cache).collect do |posting|
      "    #{posting}\n"
    end.join

    entry.bean_cache = entry.to_bean + "\n" + postings
  end

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
