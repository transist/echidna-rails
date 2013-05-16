class HourlyStat
  include Mongoid::Document

  field :word
  field :date, type: Date
  field :stats, type: Array # [{hour: 0, count: 1}, {hour: 1, count: 2}, {hour: 10, count: 0}]

  belongs_to :group

  scope :group_stats_in_period, ->(group_id, current_time, start_time) {
    where(group_id: group_id).
    lte(date: current_time.to_date.beginning_of_day).
    gte(date: start_time.to_date.beginning_of_day).
    asc(:date)
  }

  def self.words_stats(group_id, options={})
    current_time = options[:current_time].beginning_of_hour
    start_time = options[:start_time].beginning_of_hour
    current_time_distance = (current_time - start_time) / 1.hour.to_i

    history_stats = {}
    current_stats = {}
    self.group_stats_in_period(group_id, current_time, start_time).each do |hourly_stat|
      word = hourly_stat.word
      time = hourly_stat.date.to_time
      hourly_stat.stats.each do |stat|
        time = time.change(hour: stat["hour"])
        time_distance = (time - start_time) / 1.hour.to_i
        stat_count = stat["count"]
        if time >= start_time && time < current_time
          history_stats[word] ||= Array.new(current_time_distance, 0)
          history_stats[word][time_distance] += stat_count
        elsif time == current_time
          current_stats[word] = stat_count
        end
      end
    end
    {history_stats: history_stats, current_stats: current_stats}
  end
end
