require 'set'

class StatsAnalyzer
  def initialize(user, current_stats, history_stats)
    @user = user
    @current_stats = current_stats
    @history_stats = history_stats
    @positive_stats = []
    @negative_stats = []
    @unusual_stats = []
  end

  def analyze(limit)
    @current_stats.each do |word, current_stat|
      unless @user.has_stopword? word
        next if frequency_too_low?(word, current_stat)
        z_score = FAZScore.new(ENV['TRENDS_DECAY'].to_f, @history_stats[word].values[0..-2]).score(current_stat)
        stat = {word: word, z_score: z_score, current_stat: current_stat, history_stats: @history_stats[word]}
        if z_score > 10
          @unusual_stats << stat
        elsif z_score > 0
          @positive_stats << stat
        elsif z_score < 0
          @negative_stats << stat
        end
      end
    end
    {
      unusual_stats: json_safe(@unusual_stats.sort_by { |stat| -stat[:z_score] }[0...limit]),
      positive_stats: json_safe(@positive_stats.sort_by { |stat| -stat[:z_score] }[0...limit]),
      negative_stats: json_safe(@negative_stats.sort_by { |stat| stat[:z_score] }[0...limit])
    }
  end

  private

  def overall_average_frequency
    @overall_average_frequency ||=
      begin
        non_zero_stats_count = @history_stats.sum {|word, stats| stats.count {|time, freq| freq > 0 }}
        @history_stats.values.sum {|e| e.values.sum } / non_zero_stats_count.to_f
      end
  end

  def average_frequency(word)
    non_zero_stats_count = @history_stats[word].count {|time, freq| freq > 0 }
    @history_stats[word].values.sum / non_zero_stats_count.to_f
  end

  def frequency_too_low?(word, current_stat)
    average_frequency(word) < overall_average_frequency * 4 and
      current_stat < overall_average_frequency * 4
  end

  def json_safe(stats)
    stats.each do |stat|
      stat[:z_score] = stat[:z_score].to_s
    end
  end
end

class BaseStat
  class << self
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
              history_stats[word] ||= Hash.new(0)
              history_stats[word][time] += stat_count
            elsif time == current_time
              history_stats[word][time] += stat_count
              current_stats[word] ||= 0
              current_stats[word] += stat_count
            end
          end
        end
        Sidekiq.logger.info "#{self.name} takes #{Time.now - measure_time} to read stats for panel: #{panel.id}, start_time: #{start_time}, current_time: #{current_time}"

        measure_time = Time.now
        result = StatsAnalyzer.new(user, current_stats, history_stats).analyze(limit)
        Sidekiq.logger.info "#{self.name} takes #{Time.now - measure_time} to calc z-scores for panel: #{panel.id}, start_time: #{start_time}, current_time: #{current_time}"
        result
      end
    end

    def tweets(panel, word, options={})
      force = options[:force]
      tweet_ids = Set.new
      current_time = get_current_time(options)
      start_time = get_start_time(options)

      #Rails.cache.fetch tweets_cache_key(panel, word, start_time, current_time), expires_in: 1.day, force: force do
        self.batch_size(1000).where(word: word, :group_id.in => panel.group_ids).lte(date: current_time.send(date_convert)).gte(date: start_time.send(date_convert)).asc(:date).each do |period_stat|
          time = period_stat.date.to_time
          period_stat.stats.each do |stat|
            time = time.change(period.to_sym => stat[period])
            if time >= start_time && time <= current_time && stat["tweet_ids"]
              tweet_ids += stat["tweet_ids"]
            end
          end
        end
        Tweet.includes(:person).in(id: tweet_ids.to_a).map do |tweet|
          {
            id: tweet.id.to_s,
            person_id: tweet.person_id.to_s,
            target_id: tweet.target_id,
            content: tweet.content,
            posted_at: tweet.posted_at
          } unless tweet.spam || tweet.person.spam
        end.compact
      #end
    end
  end
end
