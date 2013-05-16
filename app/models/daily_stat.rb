class DailyStat
  include Mongoid::Document
  include Aggregateable

  field :word
  field :date, type: Date
  field :stats, type: Array # [{day: 0, count: 1}, {day: 1, count: 2}, {day: 10, count: 0}]

  belongs_to :group

  scope :group_stats_in_period, ->(group_id, current_time, start_time) {
    where(group_id: group_id).
    lte(date: current_time.to_date.beginning_of_month).
    gte(date: start_time.to_date.beginning_of_month).
    asc(:date)
  }

  def self.words_stats(group_id, options={})
    current_time = options[:current_time].beginning_of_day
    start_time = options[:start_time].beginning_of_day
    current_time_distance = (current_time - start_time) / 1.day.to_i

    history_stats = {}
    current_stats = {}
    self.group_stats_in_period(group_id, current_time, start_time).each do |daily_stat|
      word = daily_stat.word
      time = daily_stat.date.to_time
      daily_stat.stats.each do |stat|
        time = time.change(day: stat["day"])
        time_distance = (time - start_time) / 1.day.to_i
        stat_count = stat["count"]
        if time >= start_time && time < current_time
          history_stats[word] ||= Array.new(current_time_distance, 0)
          history_stats[word][time_distance] = stat_count
        elsif time == current_time
          current_stats[word] = stat_count
        end
      end
    end
    {history_stats: history_stats, current_stats: current_stats}
  end
end
