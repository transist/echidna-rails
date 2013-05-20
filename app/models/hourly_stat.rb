class HourlyStat
  include Mongoid::Document

  field :word
  field :date, type: Date
  field :stats, type: Array, default: (0..23).map {|n| {hour: n, count: 0} }

  validates :word, uniqueness: {scope: [:group, :date]}

  index({group_id: 1, date: 1, word: 1})

  belongs_to :group

  def self.record(word, group, time)
    houly_stat = HourlyStat.find_or_create_by(word: word, group: group, date: time.to_date)
    HourlyStat.collection.find(:_id => houly_stat.id, 'stats.hour' => time.hour).
      update({'$inc' => {'stats.$.count' => 1}})
  end

  def self.top_trends(panel, user, options={})
    current_time = Time.now.beginning_of_hour
    hours = options[:hours] || 7
    limit = options[:limit] || 100
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
      {word: word, z_score: FAZScore.new(0.5, history_stats[word]).score(current_stat), current_stat: current_stat}
    }.reject { |stat| user.has_stopword? stat[:word] }.sort_by { |stat| -stat[:z_score] }[0...limit]
  end
end
