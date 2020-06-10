class Amount
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

  def initialize(s)
    if m = s.strip.match(AMOUNT_REGEX)
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
