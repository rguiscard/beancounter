class Account < ApplicationRecord
  SPLIT_REGEX = /[ ]*,[ ]*/.freeze

  def currency_list
    self.currencies.try(:join, ', ')
  end

  def currency_list=(c)
    self.currencies = c.strip.split(SPLIT_REGEX).collect(&:strip)
  end
end
