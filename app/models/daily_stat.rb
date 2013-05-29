class DailyStat < BaseStat
  include Mongoid::Document

  field :word
  field :date, type: Date # Must be the first day of the month.
  field :stats, type: Array

  index({date: 1, group_id: 1, word: 1}, {unique: true})

  belongs_to :group

  before_save :set_default_stats

  def self.record(word, group, tweet)
    date = tweet.posted_at.to_date
    daily_stat = self.find_or_create_by(word: word, group: group, date: date.beginning_of_month)
    self.collection.find(:_id => daily_stat.id, 'stats.day' => date.mday).
      update('$inc' => {'stats.$.count' => 1}, '$push' => {'stats.$.tweet_ids' => tweet.id})
  end

  def self.tweets(panel, word, options={})
    tweet_ids = []
    current_time = get_current_time(options)
    start_time = get_start_time(options)

    Rails.cache.fetch "daily_tweets:#{start_time.to_i}:#{current_time.to_i}:#{panel.group_ids.join(',')}:#{word}" do
      self.where(:word => word, :group_id.in => panel.group_ids).gte(date: start_time.beginning_of_month).asc(:date).each do |daily_stat|
        time = daily_stat.date.to_time
        daily_stat.stats.each do |stat|
          time = time.change(day: stat["day"])
          if time >= start_time && time <= current_time && stat["tweet_ids"]
            tweet_ids += stat["tweet_ids"]
          end
        end
      end
      find_tweets(tweet_ids)
    end
  end

  private

  def self.get_current_time(options)
    live = options[:live] || false
    (live ? Time.now : 1.day.ago).beginning_of_day
  end

  def self.get_start_time(options)
    days = options[:days] || 7
    days.days.ago.beginning_of_day
  end

  def self.top_trends_cache_key(panel, start_time, current_time)
    "daily_top_trends:#{start_time.to_i}:#{current_time.to_i}:#{panel.group_ids.join(',')}"
  end

  def self.expires_in
    31.day
  end

  def self.date_convert
    :beginning_of_month
  end

  def self.period
    "day"
  end

  def set_default_stats
    self.stats ||= begin
                     days_in_month = Time.days_in_month(date.month, date.year)
                     (1..days_in_month).map {|n| {'day' => n, 'count' => 0} }
                   end
  end
end
