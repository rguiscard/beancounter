class ParseService
  ENTRY_REGEX = /^\s*(?<date>\d{4}-\d{2}-\d{2})\s+(?<directive>\S+)\s+(?<arguments>.*)$/
  POSTING_REGEX = /^\s*(?<flag>!?\s*)(?<account>\S+)\s+(?<amount>[^;]+)(?<comment>;.*)?/
  OPEN_REGEX = /(?<name>\S+)\s*(?<currency>.*)/

  def self.validate(content)
    self.parse(content, pretend: true)
  end

  # yield account or entry
  def self.parse(content, pretend: false)
    errors = []
    txn_entry = nil
    content.each_line(chomp: true) do |line|
      if line.blank?
      elsif m = line.match(ENTRY_REGEX)
        data = {
          date: m[:date],
          directive: m[:directive],
          arguments: m[:arguments],
        }
        txn_entry = nil

        case m[:directive].downcase
        when 'open'
          booking = nil
          x = m[:arguments].chomp
          if x.include?("STRICT")
            booking = "STRICT"
            x.delete!("STRICT")
          elsif x.include?("NONE")
            booking = "NONE"
            x.delete!("NONE")
          end
          if mm = x.match(OPEN_REGEX)
            data[:name] = mm[:name]
            data[:currency_list] = mm[:currency]
            yield :entry, data if block_given?
          else
            errors << "Cannot get account name: #{line}"
          end
        when 'close'
          data[:name] = m[:arguments]
          yield :entry, data if block_given?
        when 'txn', '*', '!'
          txn_entry = line
          yield :entry, data if block_given?
        when 'balance', 'pad'
          yield :entry, data if block_given?
        else
          p "Unknown directive #{m[2]}" unless pretend
        end
      elsif txn_entry.present? && m = line.match(POSTING_REGEX)
        data = {
          account: m[:account],
          amount: m[:amount],
          comment: m[:comment]
        }
        yield :posting, data if block_given?
      else
        txn_entry = nil
        errors << "Unknown entry: #{line}"
      end
    end
    errors.presence
  end
end
