class DailyStat < BaseStat
  include Mongoid::Document

  field :word
  field :date, type: Date # Must be the first day of the month.
  field :stats, type: Array

  index({group_id: 1, date: 1, word: 1}, {unique: true})

  belongs_to :group

  before_save :set_default_stats

  def self.record(word, group, tweet)
    date = tweet.posted_at.to_date
    daily_stat = self.find_or_create_by(word: word, group: group, date: date.beginning_of_month)
    self.collection.find(:_id => daily_stat.id, 'stats.day' => date.mday).
      update('$inc' => {'stats.$.count' => 1}, '$push' => {'stats.$.tweet_ids' => tweet.id})
  end

  def self.top_trends(panel, user, options={})
    current_time = Time.now.beginning_of_day
    days = options[:days] || 7
    limit = options[:limit] || 100
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
    aggregate(history_stats, current_stats, user, limit)
  end

  def self.tweets(panel, word, options={})
    tweet_ids = []
    current_time = Time.now.beginning_of_day
    days = options[:days] || 7
    start_time = current_time.ago(days.days)
    panel.groups.each do |group|
      self.where(word: word, group_id: group.id).gte(date: start_time.beginning_of_month).asc(:date).each do |daily_stat|
        time = daily_stat.date.to_time
        daily_stat.stats.each do |stat|
          time = time.change(day: stat["day"])
          if time >= start_time && stat["tweet_ids"]
            tweet_ids += stat["tweet_ids"]
          end
        end
      end
    end
    Tweet.find(tweet_ids.uniq).map { |tweet| { target_id: tweet.target_id, content: tweet.content, posted_at: tweet.posted_at } }
  end

  private

  def set_default_stats
    self.stats ||= begin
                     days_in_month = Time.days_in_month(date.month, date.year)
                     (1..days_in_month).map {|n| {'day' => n, 'count' => 0} }
                   end
  end
end
