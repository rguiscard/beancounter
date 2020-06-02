class Account < ApplicationRecord
  SPLIT_REGEX = /[ ]*,[ ]*/.freeze

  belongs_to :user
  has_many :balances
  has_many :postings

  scope :account, -> (type) { where("accounts.name ilike ?", "#{type}%") }
  scope :assets, -> { account('assets') }
  scope :liabilities, -> { account('liabilities') }
  scope :expenses, -> { account('expenses') }
  scope :income, -> { account('income') }
  scope :equity, -> { account('equity') }

  def currency_list
    self.currencies.try(:join, ', ')
  end

  def currency_list=(c)
    self.currencies = c.strip.split(SPLIT_REGEX).collect(&:strip)
  end
end
