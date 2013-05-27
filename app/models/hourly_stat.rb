class HourlyStat < BaseStat
  include Mongoid::Document

  field :word
  field :date, type: Date
  field :stats, type: Array, default: (0..23).map {|n| {hour: n, count: 0} }

  index({date: 1, group_id: 1, word: 1}, {unique: true})

  belongs_to :group

  def self.record(word, group, tweet)
    time = tweet.posted_at
    houly_stat = self.find_or_create_by(word: word, group: group, date: time.to_date)
    self.collection.find(:_id => houly_stat.id, 'stats.hour' => time.hour).
      update('$inc' => {'stats.$.count' => 1}, '$push' => {'stats.$.tweet_ids' => tweet.id})
  end

  def self.tweets(panel, word, options={})
    tweet_ids = []
    current_time = get_current_time(options)
    start_time = get_start_time(options)
    Rails.cache.fetch "hourly_tweets:#{start_time.to_i}:#{current_time.to_i}:#{panel.group_ids.join(',')}:#{word}" do
      self.where(:word => word, :group_id.in => panel.group_ids).lte(date: current_time.to_date).gte(date: start_time.to_date).asc(:date).each do |hourly_stat|
        time = hourly_stat.date.to_time
        hourly_stat.stats.each do |stat|
          time = time.change(hour: stat["hour"])
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
    (live ? Time.now : 1.hour.ago).beginning_of_hour
  end

  def self.get_start_time(options)
    hours = options[:hours] || 7
    hours.hours.ago.beginning_of_hour
  end

  def self.top_trends_cache_key(panel, start_time, current_time)
    "hourly_top_trends:#{start_time.to_i}:#{current_time.to_i}:#{panel.group_ids.join(',')}"
  end

  def self.top_trends_map
    %Q{
      function() {
        var date = this.date;
        for (var index = 0; index < this.stats.length; index ++) {
          var stat = this.stats[index];
          date.setHours(stat["hour"]);
          var timestamp = date.getTime() / 1000;
          if (timestamp >= start_timestamp && timestamp <= current_timestamp) {
            emit(this.word, {timestamp: timestamp, count: stat["count"]});
          }
        }
      }
    }
  end

  def self.date_convert
    :beginning_of_day
  end
end
