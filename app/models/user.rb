class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :entries, inverse_of: :user
  has_many :postings, through: :entries
  has_many :accounts, inverse_of: :user
  has_many :expenses, inverse_of: :user # to cache csv from bean-query

  def delete_beancount
    update_attribute(:beancount, "")
  end

  def beancount
    if super.blank? || (self.beancount_updated_at.present? && (self.entries.empty? == false) && (self.beancount_updated_at < self.entries.maximum(:updated_at)))
      content = self.entries.pluck(:bean_cache).join
      update(beancount: content, beancount_updated_at: DateTime.current)
    end
    super
  end

  def save_beancount(path: nil)
    if path.blank?
      file = Tempfile.new('beancounter')
      file.binmode
    else
      file = File.open(path)
    end

    begin
      file.write(self.beancount)
    ensure
      file.close
    end
    file.path
  end
end
