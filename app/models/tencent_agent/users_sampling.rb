class TencentAgent
  module UsersSampling
    extend ActiveSupport::Concern

    def sample_users
      $logger.info log('Sampling Users...')

      while keyword = random_keyword
        $logger.info log(%{Gathering first user from tweets of keyword "#{keyword}"...})
        result = get('api/search/t', keyword: keyword, pagesize: 30)

        if result['ret'].to_i.zero?

          unless result['data']
            $logger.info log(%{No results for keyword "#{keyword}"})
            next
          end

          user_name = result['data']['info'].first['name']

          sample_user(user_name, keyword)

        else
          $logger.error log("Failed to gather user: #{result['msg']}")
          break
        end

        sleep 5
      end

      $logger.info log('Finished users gathering')

    rescue Error => e
      $logger.error log("Aborted users gathering: #{e.message}")
    rescue => e
      log_unexpected_error(e)
    end

    def sample_user(user_name, keyword = nil)
      result = get('api/user/other_info', name: user_name)

      if result['ret'].to_i.zero? && result['data']
        user = UserDecorator.decorate(result['data'])
        publish_user(user)
      else
        $logger.error log(%{Failed to gather profile of user "#{user_name}"})
      end
      false
    end

    private

    def random_keyword
      ["公知", "淘宝", "皮鞋", "大象", "豆瓣"].sample
    end

    def publish_user(user)
      $logger.info log(%{Publishing user "#{user['name']}"})
      # TODO: Add this user to sidekiq queue

      # $redis.lpush 'streaming/messages', {
      #   type: 'add_user',
      #   body: {
      #     id: user['name'],
      #     type: 'tencent',
      #     birth_year: user['birth_year'],
      #     gender: user['gender'],
      #     city: user['city']
      #   }
      # }.to_json
    end
  end
end
