class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :entries
  has_many :postings, through: :entries
  has_many :accounts

  def save_beancount(path: nil)
    content = self.entries.collect do |entry|
      s = entry.to_bean+"\n"
      s = s + entry.postings.collect do |posting|
        "  "+posting.to_bean
      end.join("\n")
    end.join("\n")

    if path.blank?
      file = Tempfile.new('beancounter')
    else
      file = File.open(path)
    end

    begin
      file.write(content)
    ensure
      file.close
    end
    file.path
  end
end
