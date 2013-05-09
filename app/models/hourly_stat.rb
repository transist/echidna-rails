class HourlyStat
  include Mongoid::Document

  field :word
  field :group_id, type: Integer
  field :date, type: Date
  field :stats, type: Array # [{hour: 0, count: 1}, {hour: 1, count: 2}, {hour: 10, count: 0}]

  def self.top_trends(group_id, options={})
    current_time = Time.now
    hours = options[:hours] || 7
    start_time = current_time.ago(hours.hours)

    HourlyStat.where(group_id: group_id).lte(date: current_time.to_date).gte(date: start_time.to_date).sort_by { |hourly_stat|
      history_stats = []
      current_stat = 0
      time = hourly_stat.date.to_time
      hourly_stat.stats.each do |stat|
        time.change(hour: stat["hour"])
        stat_count = stat["count"]
        if time >= start_time && time < current_time
          history_stats << stat_count
        elsif time == current_time
          current_stat = stat_count
        end
      end
      FAZScore.new(0.5, history_stats).score(current_stat)
    }.map(&:word)
  end
end
