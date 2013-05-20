class TrendsWorker
  include SidekiqStatus::Worker
  sidekiq_options :queue => :trends

  def perform(panel_id, user_id, length, period)
    Sidekiq.logger.info "panel_id: #{panel_id}, user_id: #{user_id}, length: #{length}, period: #{period}"
    panel = Panel.find(panel_id)
    user = User.find(user_id)
    self.payload = period == "days" ? DailyStat.top_trends(panel, user, days: length) : HourlyStat.top_trends(panel, user, hours: length)
  end
end
