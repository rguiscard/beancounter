require 'csv'

class AssetTrendJob < ApplicationJob
  queue_as :default

  def perform(user, asset)
    path = Pathname.new(user.save_beancount)
    query = "SELECT year(date) as year, month(date) as month, sum(cost(position)) as sum, last(cost(balance)) as balance WHERE account ~ \'#{asset}\' GROUP BY year, month ORDER BY year, month"
    content =  %x(bean-query -q -f csv #{path} \"#{query}\")

    trend = user.trends.find_or_create_by(name: asset)
    trend.update_attribute(:data, content)

    # also remove unused cache
    user.trends.where("updated_at < ?", DateTime.current-366.days).destroy_all
  end

end
