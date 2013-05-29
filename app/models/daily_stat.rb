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

  def self.tweets_cache_key(panel, word, start_time, current_time)
    "daily_tweets:#{start_time.to_i}:#{current_time.to_i}:#{panel.group_ids.join(',')}:#{word}"
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
