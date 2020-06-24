class Account < ApplicationRecord
  store_accessor :preferences, :invisible # invisible from navigation menu

  validates :name, uniqueness: true
  validates :name, presence: true

  SPLIT_REGEX = /[ ]*,[ ]*/.freeze

  before_destroy :associate_entries
  before_update  :associate_entries
  after_update   :change_account_name

  belongs_to :user, inverse_of: :accounts
  has_many :balances, inverse_of: :account
  has_many :entries, inverse_of: :account
  has_many :postings, inverse_of: :account

  scope :account, -> (type) { where("accounts.name ilike ?", "#{type}%") }
  scope :assets, -> { account('assets') }
  scope :liabilities, -> { account('liabilities') }
  scope :expenses, -> { account('expenses') }
  scope :income, -> { account('income') }
  scope :equity, -> { account('equity') }

  scope :visible, -> { where("(preferences ->> 'invisible')::boolean = ?", false) }

  # If account name is change, also change associated entries
  def change_account_name
    if self.name_previously_changed?
      old_name = self.previous_changes["name"].first
      if old_name.present?
        self.entries.each do |entry|
          arguments = entry.arguments.sub(old_name, self.name)
          entry.update(arguments: arguments)
        end
      end
      # because account is changed, bean_cache of post need to change, too.
      self.postings.each(&:save)
    end
  end

  # Some entries might not be associted to this account through the import of other means.
  # Therefore, it has to be associated before destroy or other actions can happen
  def associate_entries
    name = (self.name_changed? ? self.name_was : self.name)
    entries = self.user.entries.where(directive: ['open', 'balance', 'pad', 'close'])
    entries = entries.where("arguments ilike ?", "#{name} %").or(entries.where(arguments: name))
    entries.where(account: nil).update_all(account_id: self.id)
    entries
  end

  def display_name(both: false)
    if both
      self.nickname.present? ? "#{self.nickname} (#{self.name})" : self.name
    else
      self.nickname.presence || self.name.presence
    end
  end

  def currency_list
    self.currencies.try(:join, ', ')
  end

  def currency_list=(c)
    self.currencies = c.strip.split(SPLIT_REGEX).collect(&:strip)
  end
end
