class HourlyStat < BaseStat
  include Mongoid::Document

  field :word
  field :date, type: Date
  field :stats, type: Array, default: (0..23).map {|n| {hour: n, count: 0} }

  index({date: 1, group_id: 1, word: 1}, {unique: true})

  belongs_to :group

  class <<self
    def record(word, group, tweet)
      time = tweet.posted_at
      hourly_stat = self.find_or_create_by(word: word, group: group, date: time.to_date)
      self.collection.find(:_id => hourly_stat.id, 'stats.hour' => time.hour).
        update('$inc' => {'stats.$.count' => 1}, '$push' => {'stats.$.tweet_ids' => tweet.id})
    end

    def remove(word, group, tweet)
      time = tweet.posted_at
      hourly_stat = self.where(word: word, group: group, date: time.to_date).first
      self.collection.find(:_id => hourly_stat.id, 'stats.hour' => time.hour).
        update('$inc' => {'stats.$.count' => -1}, '$pull' => {'stats.$.tweet_ids' => tweet.id})
    end

    private
    def get_current_time(options)
      live = options[:live] || false
      (live ? Time.now : 1.hour.ago).beginning_of_hour
    end

    def get_start_time(options)
      hours = options[:hours] || 7
      hours.hours.ago.beginning_of_hour
    end

    def top_trends_cache_key(panel, start_time, current_time)
      "hourly_top_trends:#{start_time.to_i}:#{current_time.to_i}:#{panel.group_ids.join(',')}"
    end

    def tweets_cache_key(panel, word, start_time, current_time)
      "hourly_tweets:#{start_time.to_i}:#{current_time.to_i}:#{panel.group_ids.join(',')}:#{word}"
    end

    def expires_in
      1.day
    end

    def date_convert
      :to_date
    end

    def period
      "hour"
    end
  end
end
