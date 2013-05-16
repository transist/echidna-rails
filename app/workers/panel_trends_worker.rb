class PanelTrendsWorker
  include SidekiqStatus::Worker

  def perform(panel_id, length, period)
    panel = Panel.find(panel_id)
    group_job_ids = panel.groups.map { |group| GroupTrendsWorker.perform_async(group.id, length, period) }
    history_stats = {}
    current_stats = {}

    while true
      group_job_ids.each do |job_id|
        unless current_stats[job_id]
          @job = SidekiqStatus::Container.load(job_id)
          if @job.status == "complete"
            payload = @job.payload
            history_stats[job_id] = payload["history_stats"]
            current_stats[job_id] = payload["current_stats"]
          end
        end
      end
      if group_job_ids.all? { |job_id| current_stats[job_id] }
        break
      else
        sleep 1
      end
    end

    self.payload = AggregateStat.words_scores(history_stats.values, current_stats.values)
  end
end
