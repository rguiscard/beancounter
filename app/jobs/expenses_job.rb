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
    if expense = user.expenses.find_or_create_by(year: year, month: month)
      expense.update_attributes(details: content, updated_at: DateTime.current)
    end
  end
end
