class GroupTrendsWorker
  include SidekiqStatus::Worker

  def perform(group_id, length, period)
    current_time = Time.now
    start_time = start_time(length, period)
    self.payload = stat_class(period).words_stats(group_id, current_time: current_time, start_time: start_time)
  end

  def stat_class(period)
    if period == "days"
      DailyStat
    else
      HourlyStat
    end
  end

  def start_time(length, period)
    if period == "days"
      length.days.ago
    else
      length.hours.ago
    end
  end
end
