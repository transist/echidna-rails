class GroupTrendsWorker
  include SidekiqStatus::Worker

  def perform(group_id, length, period)
    current_time = Time.now.beginning_of_day
    days = options[:days] || 7
    start_time = current_time.ago(days.days)
  end
end
