class TencentAgent
  module TweetsGathering
    extend ActiveSupport::Concern

    GATHER_TWEET_WAIT = 0.2

    def gather_tweets
      tencent_lists.each do |tencent_list|
        begin
          gather_tweets_from_list(tencent_list)
        rescue TencentError => e
          error "Aborted tweets gathering: #{e.message}"
        rescue => e
          log_unexpected_error(e)
        end
      end

      info 'Finished tweets gathering'
    end

    private

    def gather_tweets_from_list(tencent_list)
      info "Gathering tweets from list #{tencent_list.name} since #{tencent_list.latest_tweet_timestamp}..."

      loop do
        result = tencent_list.gather_tweets_since_latest_known_tweet

        if result['ret'].to_i.zero?
          unless result['data']
            info 'No new tweets (when ret code is zero)'
            break
          end

          info 'Gathered tweets...'
          tencent_list.publish_tweets(result['data']['info'])
          break if result['data']['hasnext'].zero?

        elsif result['ret'].to_i == 5 && result['errcode'].to_i == 5
          info('No new tweets')
          break

        else
          error("Failed to gather tweets: #{result['msg']}")

          break
        end

        sleep GATHER_TWEET_WAIT
      end
      sleep GATHER_TWEET_WAIT
    end
  end
end
