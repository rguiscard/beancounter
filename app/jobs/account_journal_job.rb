class AccountJournalJob < ApplicationJob
  queue_as :default

  def perform(user, account)
    path = Pathname.new(user.save_beancount)
    query="SELECT date, account, narration, position, balance WHERE account ~ \"#{account.name}\" ORDER BY date DESC;"
    content =  %x(bean-query -q -f csv #{path} '#{query}')
    account.update(journal: content, journal_cached_at: DateTime.current)
  end
end
