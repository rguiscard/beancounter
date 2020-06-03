class Entry < ApplicationRecord
  enum directive: [:txn, :open, :close, :commodity, :balance, :pad, :note, :document, :price, :event, :query, :custom, :asterisk, :exclamation]

  belongs_to :user
  has_many :postings

  before_save :assign_bean_cache
  after_touch do |entry| entry.save end # this trigger the creation of bean_cache

  scope :transactions, -> { where(directive: [:txn, :asterisk, :exclamation]) }

  def transaction?
    self.txn? || self.asterisk? || self.exclamation?
  end

  # to_bean does not include postings. bean_cache does include postings, though.
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

  private

    def assign_bean_cache
      postings = self.postings.pluck(:bean_cache).collect do |posting|
        "    #{posting}\n"
      end.join

      self.bean_cache = self.to_bean + "\n" + postings
    end

end
