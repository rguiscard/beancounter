class AccountDetailsJob < ApplicationJob
  queue_as :default

  def perform(account)
    path = Pathname.new(Entry.save_to_tempfile)
    query="SELECT date, account, narration, position, balance WHERE account ~ \"#{account.name}\" ORDER BY date DESC;"
    content =  %x(bean-query -q -f csv #{path} '#{query}')
    account.journal = content
    
#    CSV.parse(content, {headers: :first_row}) do |row|
#      puts row
#      if account = Account.find_by(name: row["account"].strip)
#        x = row["sum_position"].strip.split(" ")
#        account.balances.find_or_create_by(currency: x[1]) do |balance|
#          balance.amount = x[0]
#        end
#      else
#        puts "Cannot find account: #{row["account"].strip}"
#      end
#    end
  end
end
