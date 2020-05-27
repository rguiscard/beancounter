require 'csv'

class AccountBalanceJob < ApplicationJob
  queue_as :default

  def perform(*args)
    path = Pathname.new(Entry.save_to_tempfile)
    content =  %x(bean-query -q -f csv #{path} 'balances where account ~ "Assets|Liabilities"')
    CSV.parse(content, {headers: :first_row}) do |row|
      puts "**#{row["account"].strip}**"
      if account = Account.find_by(name: row["account"].strip)
        x = row["sum_position"].strip.split(" ")
        account.balances.find_or_create_by(currency: x[1]) do |balance|
          balance.amount = x[0]
        end
      else
        puts "Cannot find account: #{row["account"].strip}"
      end
    end
  end
end
