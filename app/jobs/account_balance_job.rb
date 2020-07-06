require 'csv'

class AccountBalanceJob < ApplicationJob
  queue_as :default

  def perform(user)
    path = Pathname.new(user.save_beancount)
    content =  %x(bean-query -q -f csv #{path} 'balances where account ~ "Assets|Liabilities"')
    CSV.parse(content, headers: :first_row, converters: ->(f) { f.strip }) do |row|
      if account = user.accounts.find_by(name: row["account"])
        if row["sum_position"].blank?
          account.balances.destroy_all
        else
          currencies = account.balances.pluck(:currency) # existing currencies

          # There is a possibility that beancount will round up cost.
          # Therefore, it will output several sum_position with seemly identical cost
          # but they are actually different in small value
          # sum_positions = Hash.new(0)
          # row["sum_position"].split(',').inject(sum_positions) do |hash, sum|
          #   if (amount = Amount.new(sum)) && (amount.blank? == false)
          #     currency = [amount.currency, amount.cost].compact.join(" ")
          #     hash[currency] += amount.number.to_f
          #   end
          #   hash
          # end
          sum_positions = Amount.combine_positions(row["sum_position"])

          sum_positions.each do |amount|
            currency = "#{amount.currency} #{amount.cost}"
            currencies.delete(currency)
            if balance = account.balances.find_or_create_by(currency: currency)
              balance.update(amount: amount.number, updated_at: DateTime.current)
            end
          end

          # Remove non-existing currency
          account.balances.where(currency: currencies).destroy_all
        end
      else
        puts "Cannot find account: #{row["account"]}"
        puts row
      end
    end
  end

end
