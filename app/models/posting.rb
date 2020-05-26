class Posting < ApplicationRecord
  belongs_to :entry
  belongs_to :account

  def to_bean
    words = []
    words << self.flag if self.flag.present?
    words << self.account.name
    words << self.arguments
    words.join(' ')
  end
end
