class ParseService
  ENTRY_REGEX = %r{
    ^\s*(?<date>\d{4}-\d{2}-\d{2})\s+(?<directive>\S+)\s+(?<arguments>.*)$
  }x

  POSTING_REGEX = %r{
    ^\s*(?<flag>!?\s*)
    (?<account>(Assets|Liabilities|Income|Expenses|Equity):\S+)
    \s*
    (?<arguments>[^;]*)(?<comment>;.*)?
  }x

  META_REGEX = %r{
    ^\s*
    (?<key>[a-z][^:]*):\s*(?<value>\S*)
  }x

  TAG_REGEX = %r{ (\#(?<tag>[^\s\;\"]+)) }x

  LINK_REGEX = %r{ (\^(?<link>[^\s\;\"]+)) }x

  ACCOUNT_REGEX = %r{
    (?<name>(Assets|Liabilities|Income|Expenses|Equity):\S+)
    \s*
    (?<options>.*)
  }x

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
          tags: m[:arguments].scan(TAG_REGEX).flatten,
          links: m[:arguments].scan(LINK_REGEX).flatten
        }
        txn_entry = nil

        case m[:directive].downcase
        when 'open'
          booking = nil
          x = m[:arguments].strip
          if x.include?("STRICT")
            booking = "STRICT"
            x.delete!("STRICT")
          elsif x.include?("NONE")
            booking = "NONE"
            x.delete!("NONE")
          end
          if mm = x.match(ACCOUNT_REGEX)
            data[:name] = mm[:name]
            data[:currency_list] = mm[:options]
            yield :entry, data if block_given?
          else
            errors << "Cannot get account name: #{line}"
          end
        when 'close'
          data[:name] = m[:arguments].strip
          yield :entry, data if block_given?
        when 'txn'
          txn_entry = line
          yield :entry, data if block_given?
        when '*'
          txn_entry = line
          data[:directive] = 'asterisk'
          yield :entry, data if block_given?
        when '!'
          txn_entry = line
          data[:directive] = 'exclamation'
          yield :entry, data if block_given?
        when 'balance', 'pad'
          x = m[:arguments].strip
          if mm = x.match(ACCOUNT_REGEX)
            data[:name] = mm[:name]
            yield :entry, data if block_given?
          else
            errors << "Cannot get account name: #{line}"
          end
        else
          p "Unknown directive #{m[2]}" unless pretend
        end
      elsif txn_entry.present? && m = line.match(POSTING_REGEX)
        data = {
          account: m[:account],
          arguments: m[:arguments],
          comment: m[:comment]
        }
        yield :posting, data if block_given?
      elsif m = line.match(META_REGEX)
        data = {
          key: m[:key],
          value: m[:value]
        }
        yield :meta, data if block_given?
      else
        txn_entry = nil
        errors << "Unknown entry: #{line}"
      end
    end
    errors.presence
  end
end
