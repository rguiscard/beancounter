module AccountsHelper
  # list is an array of account name like ["Assets", "Assets:US", "Assets:US:BoA", "Assets:US:BankOne"]
  # This returns immediate sub-account of account.
  def sub_accounts(account, list)
    str = []
    str << account
    subs = list.select { |x| x.start_with?("#{account}:") && (x.count(":") == account.count(":")+1) }
    if subs.count > 0
      subs.each do |sub|
        str << sub_accounts(sub, list)
      end
    end
    str
  end
end
