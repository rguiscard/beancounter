class Entry < ApplicationRecord
  enum directive: [:txn, :open, :close, :commodity, :balance, :pad, :note, :document, :price, :event, :query, :custom, :asterisk, :exclamation]

  validates :arguments, presence: true
  validates_associated :postings

  before_save :assign_bean_cache
  before_save :extract_tags
  after_destroy :delete_account_journal
  after_touch do |entry| entry.save end # this trigger the creation of bean_cache
  after_touch :delete_account_journal # trigger account journal updated

  belongs_to :user, inverse_of: :entries
  belongs_to :account, inverse_of: :entries, optional: true
  has_many :postings, inverse_of: :entry
  accepts_nested_attributes_for :postings

  scope :transactions, -> { where(directive: [:txn, :asterisk, :exclamation]) }
  ["tags", "links"].each do |names|
    name = names.singularize
    scope :"with_any_{name}", ->(tags){ where("#{names} && ARRAY[?]", TagService.parse(tags)) }
    scope :"with_all_#{names}", ->(tags){ where("#{names} @> ARRAY[?]", TagService.parse(tags)) }
    scope :"all_#{names}", -> { pluck(Arel.sql("distinct unnest(#{names})")) }
  end

  # Entries having postings associated with account.
  # Do not confuse with entries which directly associate with account, such as open, pad and balance directive
  scope :with_account, -> (account) { left_joins(postings: :account).where("postings.account_id = ? OR entries.account_id = ?", account, account).distinct }

  def transaction?
    self.txn? || self.asterisk? || self.exclamation?
  end

  # to_bean does not include postings. bean_cache does include postings, though.
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

  private

    def extract_tags
      ParseService.parse(self.to_bean) do |klass, data|
        if @errors.blank?
          case klass
          when :entry
            self.tags = data[:tags]
            self.links = data[:links]
          end
        end
      end
    end

    def assign_bean_cache
      postings = self.postings.pluck(:bean_cache).collect do |posting|
        "    #{posting}\n"
      end.join

      self.bean_cache = self.to_bean + "\n" + postings
    end

    # remove journal cache in account
    def delete_account_journal
      if account = self.account
        account.update_attribute(:journal_cached_at, nil)
      end

      self.postings.each do |posting|
        posting.account.update_attribute(:journal_cached_at, nil)
      end
    end

end
