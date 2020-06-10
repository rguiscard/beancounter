require 'csv'

class AccountBalanceJob < ApplicationJob
  queue_as :default

  def perform(user)
    path = Pathname.new(user.save_beancount)
    content =  %x(bean-query -q -f csv #{path} 'balances where account ~ "Assets|Liabilities"')
    CSV.parse(content, {headers: :first_row}) do |row|
      if account = user.accounts.find_by(name: row["account"].strip)
        if row["sum_position"].blank?
          account.balances.destroy_all
        else
          currencies = account.balances.pluck(:currency) # existing currencies
          row["sum_position"].split(',').each do |sum|
            if (amount = Amount.new(sum)) && (amount.blank? == false)
              currency = [amount.currency, amount.cost].compact.join(" ")
              currencies.delete(currency)
              if balance = account.balances.find_or_create_by(currency: currency)
                balance.update(amount: amount.number, updated_at: DateTime.current)
              end
            end
          end
          # Remove non-existing currency
          account.balances.where(currency: currencies).destroy_all
        end
      else
        puts "Cannot find account: #{row["account"].strip}"
        puts row
      end
    end
  end

end
