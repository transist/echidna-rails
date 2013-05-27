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

  def self.top_trends(panel, user, options={})
    limit = options[:limit] || 100
    current_time = get_current_time(options)
    start_time = get_start_time(options)

    history_stats = {}
    current_stats = {}
    self.where(:group_id.in => panel.group_ids).lte(date: current_time.to_date).gte(date: start_time.to_date).asc(:date).each do |hourly_stat|
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
    aggregate(history_stats, current_stats, user, limit)
  end

  def self.tweets(panel, word, options={})
    tweet_ids = []
    current_time = get_current_time(options)
    start_time = get_start_time(options)
    self.where(:word => word, :group_id.in => panel.group_ids).lte(date: current_time.to_date).gte(date: start_time.to_date).asc(:date).each do |hourly_stat|
      time = hourly_stat.date.to_time
      hourly_stat.stats.each do |stat|
        time = time.change(hour: stat["hour"])
        if time >= start_time && time <= current_time && stat["tweet_ids"]
          tweet_ids += stat["tweet_ids"]
        end
      end
    end
    Tweet.find(tweet_ids.uniq).map { |tweet| { target_id: tweet.target_id, content: tweet.content, posted_at: tweet.posted_at } }
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
end
