class PanelTrendsWorker
  include SidekiqStatus::Worker

  def perform(panel_id, length, period)
    panel = Panel.find(panel_id)
    group_job_ids = panel.groups.map { |group| GroupTrendsWorker.perform_async(group.id, length, period) }

    self.payload = period == "days" ? DailyStat.top_trends(panel, days: length) : HourlyStat.top_trends(panel, hours: length)
  end
end
