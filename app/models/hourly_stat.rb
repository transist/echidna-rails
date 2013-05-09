class HourlyStat
  include Mongoid::Document

  field :word
  field :group_id, type: Integer
  field :date, type: Date
  field :stats, type: Array # [{hour: 0, count: 1}, {hour: 1, count: 2}, {hour: 10, count: 0}]

  def self.top_trends(group_id, options={})
    current_hour = Time.now.hour
    history_interval = options[:hours] || 7
    start_hour = current_hour - history_interval
    HourlyStat.where(group_id: group_id, date: Date.today).sort_by { |hourly_stat|
      history_stats = []
      current_stat = 0
      hourly_stat.stats.each do |stat|
        stat_hour = stat["hour"]
        stat_count = stat["count"]
        if stat_hour >= start_hour && stat_hour < current_hour
          history_stats << stat_count
        elsif stat_hour == current_hour
          current_stat = stat_count
        end
      end
      FAZScore.new(0.5, history_stats).score(current_stat)
    }.map(&:word)
  end
end
