class Account < ApplicationRecord
  SPLIT_REGEX = /[ ]*,[ ]*/.freeze

  enum directive: [:open, :close]

  def currency_list
    self.currencies.try(:join, ', ')
  end

  def currency_list=(c)
    self.currencies = c.strip.split(SPLIT_REGEX).collect(&:strip)
  end

  def to_bean
    words = [date.strftime('%Y-%m-%d')]
    # words << (self.open? ? 'open' : 'close')
    words << self.directive
    words << self.name
    words << self.currency_list

    words.join(' ')
  end
end
