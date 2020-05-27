class Entry < ApplicationRecord
  enum directive: [:txn, :open, :close, :commodity, :balance, :pad, :note, :document, :price, :event, :query, :custom, :asterisk, :exclamation]

  has_many :postings

  def self.save_to_tempfile
    content = Entry.all.collect do |entry|
      s = entry.to_bean+"\n"
      s = s + entry.postings.collect do |posting|
        posting.to_bean
      end.join("\n")
    end.join("\n")
    file = Tempfile.new('beancounter')
    begin
      file.write(content)
    ensure
      file.close
    end
    file.path
  end

  def transaction?
    self.txn? || self.asterisk? || self.exclamation?
  end

  def to_bean
    words = [date.strftime('%Y-%m-%d')]

    if self.asterisk?
      words << "*"
    elsif self.exclamation?
      words << "!"
    else
      words << self.directive
    end

    words << self.arguments
    words.join(' ')
  end
end
