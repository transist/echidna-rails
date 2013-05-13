class HourlyStat
  include Mongoid::Document

  field :word
  field :date, type: Date
  field :stats, type: Array # [{hour: 0, count: 1}, {hour: 1, count: 2}, {hour: 10, count: 0}]

  belongs_to :group

  def self.top_trends(panel, options={})
    current_time = Time.now.beginning_of_hour
    hours = options[:hours] || 7
    start_time = current_time.ago(hours.hours)

    history_stats = {}
    current_stats = {}
    panel.groups.each do |group|
      self.where(group_id: group.id).lte(date: current_time.to_date).gte(date: start_time.to_date).asc(:date).each do |hourly_stat|
        word = hourly_stat.word
        time = hourly_stat.date.to_time
        hourly_stat.stats.each do |stat|
          time = time.change(hour: stat["hour"])
          stat_count = stat["count"]
          if time >= start_time && time < current_time
            history_stats[word] ||= Array.new((current_time - start_time) / 1.hour.to_i, 0)
            history_stats[word][(time - start_time) / 1.hour.to_i] += stat_count
          elsif time == current_time
            current_stats[word] ||= 0
            current_stats[word] += stat_count
          end
        end
      end
    end
    current_stats.map { |word, current_stat|
      {word: word, z_score: FAZScore.new(0.5, history_stats[word]).score(current_stat)}
    }.sort_by { |stat| -stat[:z_score] }
  end
end
