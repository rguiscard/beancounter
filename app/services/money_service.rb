class MoneyService
  # turn '123 USD' to 123, 'USD'
  def self.split_amount(amount)
    x = amount.split(' ')
    return nil if x.size != 2

    if block_given?
      yield x[0], x[1]
    else
      return x[0], x[1]
    end
  end
end
