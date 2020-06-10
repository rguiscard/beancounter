require 'csv'

class AccountBalanceJob < ApplicationJob
  queue_as :default

  def perform(user)
    path = Pathname.new(user.save_beancount)
    content =  %x(bean-query -q -f csv #{path} 'balances where account ~ "Assets|Liabilities"')
    CSV.parse(content, {headers: :first_row}) do |row|
      if account = user.accounts.find_by(name: row["account"].strip)
        next if row["sum_position"].blank?
        if (amount = Amount.new(row["sum_position"])) && (amount.blank? == false)
          if balance = account.balances.find_or_create_by(currency: amount.currency)
            balance.update(amount: amount.number, updated_at: DateTime.current)
          end
        end
      else
        puts "Cannot find account: #{row["account"].strip}"
        puts row
      end
    end
  end

end
