class BaseStat
  def self.top_trends(panel, user, options={})
    limit = options[:limit] || 100
    current_time = get_current_time(options)
    start_time = get_start_time(options)

    Rails.cache.fetch top_trends_cache_key(panel, start_time, current_time) do
      current_stats = {}
      history_stats = {}
      positive_stats = []
      negative_stats = []
      zero_stats = []

      reduce = %Q{
        function(word, stats) {
          var result = {};
          stats.forEach(function(stat) {
            var timestamp = stat["timestamp"];
            if (!result[timestamp]) {
              result[timestamp] = 0;
            }
            result[timestamp] += stat["count"];

          });
          return result;
        }
      }

      self.lte(date: current_time.send(date_convert)).gte(date: start_time.send(date_convert)).in(group_id: panel.group_ids)
        map_reduce(top_trends_map, reduce).out(inline: true).scope(start_timestamp: start_time.to_i, current_timestamp: current_time.to_i).each do |document|
          word = document["_id"]
          values = document["value"].sort
          current_stats[word] = values.pop.last
          history_stats[word] = values.map(&:last)
      end

      current_stats.each { |word, current_stat|
        unless user.has_stopword? word
          z_score = FAZScore.new(0.5, history_stats[word]).score(current_stat)
          stat = {word: word, z_score: z_score, current_stat: current_stat.to_i}
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
