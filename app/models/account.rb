class Account < ApplicationRecord
  SPLIT_REGEX = /[ ]*,[ ]*/.freeze

  belongs_to :user, inverse_of: :accounts
  has_many :balances, inverse_of: :account
  has_many :postings, inverse_of: :account

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
