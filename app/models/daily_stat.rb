class DailyStat
  include Mongoid::Document

  field :word
  field :date, type: Date # Must be the first day of the month.
  field :stats, type: Array

  validates :word, uniqueness: {scope: [:group, :date]}

  index({group_id: 1, date: 1})

  belongs_to :group

  before_save :set_default_stats

  def self.record(word, group, date)
    daily_stat = DailyStat.find_or_create_by(word: word, group: group, date: date.beginning_of_month)
    DailyStat.collection.find(:_id => daily_stat.id, 'stats.day' => date.mday).
      update('$inc' => {'stats.$.count' => 1})
  end

  def self.top_trends(panel, options={})
    current_time = Time.now.beginning_of_day
    days = options[:days] || 7
    start_time = current_time.ago(days.days)

    history_stats = {}
    current_stats = {}
    panel.groups.each do |group|
      self.where(group_id: group.id).lte(date: current_time.to_date.beginning_of_month).gte(date: start_time.to_date.beginning_of_month).asc(:date).each do |daily_stat|
        word = daily_stat.word
        time = daily_stat.date.to_time
        daily_stat.stats.each do |stat|
          time = time.change(day: stat["day"])
          stat_count = stat["count"]
          if time >= start_time && time < current_time
            history_stats[word] ||= Array.new((current_time - start_time) / 1.day.to_i, 0)
            history_stats[word][(time - start_time) / 1.day.to_i] += stat_count
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

  private

  def set_default_stats
    self.stats ||= begin
                     days_in_month = Time.days_in_month(date.month, date.year)
                     (1..days_in_month).map {|n| {'day' => n, 'count' => 0} }
                   end
  end
end
