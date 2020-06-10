class Amount
  AMOUNT_REGEX=%r{
    ^
    (?<number>[0-9\.]+)\s+
    (?<currency>\S+)\s*
    (?<cost>\{.*\})?\s*
    ((?<price>@@[^;]*)|(?<unit_price>@[^;]*))?\s*
    (?<comment>;.*)?
    $
  }x

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

  def to_s
    [@number, @currency, @cost, @price, @unit_price, @comment].compact.join(" ")
  end

  def blank?
    @number.blank? && @currency.blank?
  end
end
