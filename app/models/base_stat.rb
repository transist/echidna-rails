class BaseStat
  def self.top_trends(panel, user, options={})
    limit = options[:limit] || 100
    current_time = get_current_time(options)
    start_time = get_start_time(options)
    interval = 1.send(period).to_i

    Rails.cache.fetch top_trends_cache_key(panel, start_time, current_time), expires_in: expires_in do
      history_stats = {}
      current_stats = {}
      self.where(:group_id.in => panel.group_ids).lte(date: current_time.send(date_convert)).gte(date: start_time.send(date_convert)).asc(:date).each do |period_stat|
        word = period_stat.word
        time = period_stat.date.to_time
        period_stat.stats.each do |stat|
          time = time.change(period.to_sym => stat[period])
          stat_count = stat["count"]
          if time >= start_time && time < current_time
            history_stats[word] ||= Array.new((current_time - start_time) / interval, 0)
            history_stats[word][(time - start_time) / interval] += stat_count
          elsif time == current_time
            current_stats[word] ||= 0
            current_stats[word] += stat_count
          end
        end
      end

      positive_stats = []
      negative_stats = []
      zero_stats = []

      current_stats.each { |word, current_stat|
        unless user.has_stopword? word
          z_score = FAZScore.new(0.5, history_stats[word]).score(current_stat)
          stat = {word: word, z_score: z_score, current_stat: current_stat}
          if z_score > 0
            positive_stats << stat
          elsif z_score < 0
            negative_stats << stat
          else z_score == 0
            zero_stats << stat
          end
        end
      }
      {
        positive_stats: positive_stats.sort_by { |stat| -stat[:z_score] }[0...limit],
        zero_stats: zero_stats.sort_by { |stat| -stat[:current_stat] }[0...limit],
        negative_stats: negative_stats.sort_by { |stat| stat[:z_score] }[0...limit]
      }
    end
  end

  def self.find_tweets(tweet_ids)
    Tweet.find(tweet_ids.uniq).map { |tweet| { target_id: tweet.target_id, content: tweet.content, posted_at: tweet.posted_at } }
  end
end
