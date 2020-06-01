require 'csv'

class AccountBalanceJob < ApplicationJob
  queue_as :default

  def perform(user)
    path = Pathname.new(user.save_beancount)
    content =  %x(bean-query -q -f csv #{path} 'balances where account ~ "Assets|Liabilities"')
    CSV.parse(content, {headers: :first_row}) do |row|
      if account = user.accounts.find_by(name: row["account"].strip)
        next if row["sum_position"].blank?
        MoneyService.split_amount(row["sum_position"]) do |x, y|
          if balance = account.balances.find_or_create_by(currency: y)
            balance.update_attribute(:amount, x)
          end
        end
      else
        puts "Cannot find account: #{row["account"].strip}"
        puts row
      end
    end
  end

end
