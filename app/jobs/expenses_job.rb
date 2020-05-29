class ExpensesJob < ApplicationJob
  queue_as :default

  def perform(user, year, month)
    path = Pathname.new(user.save_beancount)
    query="balances "
    if year.present?
      query = query + "FROM year = #{year} "
      if month.present?
        query = query + "and month = #{month} "
      end
    end
    query = query + "WHERE account ~ \"Expenses:*|Income:*\" "
    content =  %x(bean-query -q -f csv #{path} '#{query}')
    user.expenses.find_or_create_by(year: year, month: month) do |expense|
      expense.details = content
    end
  end
end
