class Posting < ApplicationRecord
  before_save :assign_bean_cache
  before_save :append_currency

  belongs_to :entry, inverse_of: :postings, touch: true
  belongs_to :account, inverse_of: :postings

  scope :account, -> (type) { joins(:account).where("accounts.name ilike ?", "#{type}%") }
  scope :assets, -> { account('assets') }
  scope :liabilities, -> { account('liabilities') }
  scope :expenses, -> { account('expenses') }
  scope :income, -> { account('income') }
  scope :equity, -> { account('equity') }

  def assign_bean_cache
    self.bean_cache = self.to_bean
  end

  def append_currency
    if self.arguments.present? && self.entry.present? && (user = self.entry.user.presence) && self.arguments.strip.match(Amount::NUMBER_REGEX)
      self.arguments = "#{self.arguments} #{user.currency}"
    end
  end

  def to_bean
    words = []
    words << self.flag if self.flag.present?
    words << self.account.name
    words << self.arguments
    words.join(' ')
  end
end
