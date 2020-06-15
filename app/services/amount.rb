class Amount
  # FIXME?: need to normalize cost so that space does not affect

  AMOUNT_REGEX=%r{
    ^
    (?<number>[0-9\.\-]+)\s+
    (?<currency>\S+)\s*
    (?<cost>\{.*\})?\s*
    ((?<price>@@[^;]*)|(?<unit_price>@[^;]*))?\s*
    (?<comment>;.*)?
    $
  }x

  KNOWN_CURRENCY = ['USD', 'TWD']

  attr_reader :number, :currency, :cost, :unit_price, :price, :comment

  # "10 IBM {10 USD}, 20 IBM {10 USD}, 10 IBM {11 USD}" => [:'{10 USD}' => 30, :'{11 USD}' => 10]
  def self.combine_positions(positions)
    # There is a possibility that beancount will round up cost.
    # Therefore, it will output several sum_position with seemly identical cost
    # but they are actually different in small value
    sum_positions = Hash.new(0)
    positions.split(',').inject(sum_positions) do |hash, sum|
      if (amount = Amount.new(sum)) && (amount.blank? == false)
        currency = [amount.currency, amount.cost].compact.join(" ")
        hash[currency] += amount.number.to_f
      end
      hash
    end
    sum_positions.collect do |k, v|
      Amount.new("#{v} #{k}")
    end
  end

  def initialize(s)
    if s.present? && m = s.strip.match(AMOUNT_REGEX)
      @number = m[:number]
      @currency = m[:currency]
      @cost = m[:cost]
      @price = m[:price]
      @unit_price = m[:unit_price]
      @comment = m[:comment]
    end
  end

  def to_s(format = nil)
    return nil if self.blank?

    case format
    when :long
      result = []
      if KNOWN_CURRENCY.include?(self.currency.upcase)
        result << ActiveSupport::NumberHelper::NumberToCurrencyConverter.convert(self.number, {})
      else
        result << self.number
      end
      result << self.currency
      result << self.cost
      result << (self.unit_price || self.price)
      result.compact.join(" ")
    else
      [@number, @currency, @cost, @price, @unit_price, @comment].compact.join(" ")
    end
  end

  def blank?
    @number.blank? && @currency.blank?
  end
end
