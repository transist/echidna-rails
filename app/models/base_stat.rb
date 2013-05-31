require 'set'

class BaseStat
  class <<self
    def top_trends(panel, user, options={})
      limit = options[:limit] || 100
      force = options[:force] || false
      current_time = get_current_time(options)
      start_time = get_start_time(options)
      interval = 1.send(period).to_i

      Rails.cache.fetch top_trends_cache_key(panel, start_time, current_time), expires_in: expires_in, force: force do
        history_stats = {}
        current_stats = {}
        measure_time = Time.now
        self.batch_size(1000).where(:group_id.in => panel.group_ids).lte(date: current_time.send(date_convert)).gte(date: start_time.send(date_convert)).asc(:date).each do |period_stat|
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
        Sidekiq.logger.info "#{self.name} takes #{Time.now - measure_time} to read stats for panel: #{panel.id}, start_time: #{start_time}, current_time: #{current_time}"

        positive_stats = []
        negative_stats = []
        zero_stats = []
        measure_time = Time.now
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
        Sidekiq.logger.info "#{self.name} takes #{Time.now - measure_time} to calc z-scores for panel: #{panel.id}, start_time: #{start_time}, current_time: #{current_time}"

        measure_time = Time.now
        result = {
          positive_stats: positive_stats.sort_by { |stat| -stat[:z_score] }[0...limit],
          zero_stats: zero_stats.sort_by { |stat| -stat[:current_stat] }[0...limit],
          negative_stats: negative_stats.sort_by { |stat| stat[:z_score] }[0...limit]
        }
        Sidekiq.logger.info "#{self.name} takes #{Time.now - measure_time} to sort for panel: #{panel.id}, start_time: #{start_time}, current_time: #{current_time}"
        result
      end
    end

    def tweets(panel, word, options={})
      force = options[:force]
      tweet_ids = Set.new
      current_time = get_current_time(options)
      start_time = get_start_time(options)

      #Rails.cache.fetch tweets_cache_key(panel, word, start_time, current_time), expires_in: 1.day, force: force do
        self.batch_size(1000).where(:word => word, :group_id.in => panel.group_ids).lte(date: current_time.send(date_convert)).gte(date: start_time.send(date_convert)).asc(:date).each do |period_stat|
          time = period_stat.date.to_time
          period_stat.stats.each do |stat|
            time = time.change(period.to_sym => stat[period])
            if time >= start_time && time <= current_time && stat["tweet_ids"]
              tweet_ids += stat["tweet_ids"]
            end
          end
        end
        Tweet.includes(:person).find(tweet_ids.to_a).map { |tweet| { id: tweet.id.to_s, person_id: tweet.person_id.to_s, target_id: tweet.target_id, content: tweet.content, posted_at: tweet.posted_at } unless tweet.person.spam }.compact
      #end
    end
  end
end
