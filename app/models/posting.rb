class Posting < ApplicationRecord
  belongs_to :entry
  belongs_to :account

  scope :account, -> (type) { joins(:account).where("accounts.name ilike ?", "#{type}%") }
  scope :assets, -> { account('assets') }
  scope :liabilities, -> { account('liabilities') }
  scope :expenses, -> { account('expenses') }
  scope :income, -> { account('income') }
  scope :equity, -> { account('equity') }

  def to_bean
    words = []
    words << self.flag if self.flag.present?
    words << self.account.name
    words << self.arguments
    words.join(' ')
  end
end
