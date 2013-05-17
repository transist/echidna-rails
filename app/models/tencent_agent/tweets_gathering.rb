class TencentAgent
  module TweetsGathering
    extend ActiveSupport::Concern

    GATHER_TWEET_SLEEP = 5

    def gather_tweets
      list_ids.each do |list_id|
        gather_tweets_from_list(list_id, list_last_timestamp_map[list_id])
      end

      $spider_logger.info log('Finished tweets gathering')
    rescue Error => e
      $spider_logger.error log("Aborted tweets gathering: #{e.message}")
    rescue => e
      log_unexpected_error(e)
    end

    private

    def gather_tweets_from_list(list_id, latest_tweet_timestamp)
      if ENV['ECHIDNA_SPIDER_DEBUG'] == 'true'
        latest_tweet_timestamp = 2.days.ago.to_i
      else
        latest_tweet_timestamp = latest_tweet_timestamp.blank? ? 2.days.ago.to_i : latest_tweet_timestamp
      end

      $spider_logger.info log("Gathering tweets from list #{list_id} since #{Time.at(latest_tweet_timestamp.to_i)}...")

      loop do
        result = gather_tweets_since_latest_known_tweet(list_id, latest_tweet_timestamp)

        if result['ret'].to_i.zero?
          unless result['data']
            $spider_logger.info log('No new tweets (when ret code is zero)')
            break
          end

          $spider_logger.info log('Gathered tweets...')
          latest_tweet_timestamp = publish_tweets(result['data']['info'], list_id, latest_tweet_timestamp)
          break if result['data']['hasnext'].zero?

        elsif result['ret'].to_i == 5 && result['errcode'].to_i == 5
          $spider_logger.info log('No new tweets')
          break

        else
          $spider_logger.error log("Failed to gather tweets: #{result['msg']}")

          break
        end

        sleep GATHER_TWEET_SLEEP
      end
    end

    def gather_tweets_since_latest_known_tweet(list_id, latest_tweet_timestamp)
      # 70 is the max allowed value for reqnum
      get('api/list/timeline', listid: list_id, reqnum: 70, pageflag: 2, pagetime: latest_tweet_timestamp)
    end

    def publish_tweets(tweets, list_id, latest_tweet_timestamp)
      return latest_tweet_timestamp if tweets.blank?

      $spider_logger.info log("Publishing tweets since #{Time.at(latest_tweet_timestamp.to_i)}")
      
      tweets.each do |tweet|
        tweet_attrs = {
          target_source: 'tencent',
          target_person_id: tweet['openid'],
          content: tweet['text'],
          url: "http://t.qq.com/p/t/#{tweet['id']}"
        }
        TweetWorker.perform_async(tweet_attrs)
      end

      list_last_timestamp_map[list_id] = tweets.first['timestamp']
      save
      tweets.first['timestamp']
    end
  end
end
