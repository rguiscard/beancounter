class ParseService
  ENTRY_REGEX = /^\s*(?<date>\d{4}-\d{2}-\d{2})\s+(?<directive>\S+)\s+(?<arguments>.*)$/
  POSTING_REGEX = /^\s*(?<flag>!?\s*)(?<account>\S+)\s+(?<amount>[^;]+)(?<comment>;.*)?/
  OPEN_REGEX = //

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
          if mm = x.match(/(?<name>\S+)\s*(?<currency>.*)/)
            account = {
              date: m[:date],
              directive: m[:directive],
              name: mm[:name],
              currency_list: mm[:currency],
            }
            yield account if block_given?
          else
            errors << "Cannot get account name: #{line}"
          end
        when 'close'
          account = {
            date: m[:date],
            directive: m[:directive],
            name: m[:arguments],
            currency_list: ""
          }
          yield account if block_given?
        when 'txn', '*', '!'
          txn_entry = line
          entry = {
            date: m[:date],
            directive: 'txn',
            arguments: m[:arguments]
          }
          yield entry if block_given?
        when 'balance', 'pad'
          entry = {
            date: m[:date],
            directive: m[:directive],
            arguments: m[:arguments]
          }
          yield entry if block_given?
        else
          p "Unknown directive #{m[2]}" unless pretend
        end
      elsif txn_entry.present? && m = line.match(POSTING_REGEX)
        posting = {
          account: m[:account],
          amount: m[:amount],
          comment: m[:comment]
        }
        yield posting if block_given?
      else
        txn_entry = nil
        errors << "Unknown entry: #{line}"
      end
    end
    errors.presence
  end
end
