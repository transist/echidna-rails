class TrendsWorker
  include Sidekiq::Worker

  def perform(panel_id, length, period)
    Sidekiq.logger.info "panel_id: #{panel_id}, length: #{length}, period: #{period}"
    panel = Panel.find(panel_id)
    if period == "days"
      DailyStat.top_trends(panel, days: length)
    else
      HourlyStat.top_trends(panel, hours: length)
    end
  end
end
