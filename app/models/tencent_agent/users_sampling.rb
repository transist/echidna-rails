class TencentAgent
  module UsersSampling
    extend ActiveSupport::Concern

    SAMPLE_WAIT = 5

    def sample_users
      $spider_logger.info log('Sampling Users...')

      while keyword = random_keyword
        $spider_logger.info log(%{Gathering first user from tweets of keyword "#{keyword}"...})
        result = cached_get('api/search/t', keyword: keyword, pagesize: 30)

        if result['ret'].to_i.zero?

          unless result['data']
            $spider_logger.info log(%{No results for keyword "#{keyword}"})
            next
          end

          user_name = result['data']['info'].first['name']

          sample_user(user_name)

        else
          $spider_logger.error log("Failed to gather user: #{result['msg']}")
          break
        end

        sleep SAMPLE_WAIT
      end

      $spider_logger.warn log('No more keywords in queue for users gathering') if @keywords.count.zero?

      $spider_logger.info log('Finished users gathering')

    rescue Error => e
      $spider_logger.error log("Aborted users gathering: #{e.message}")
    rescue => e
      log_unexpected_error(e)
    end

    def sample_user(query_value, opts={})
      query_type = opts.delete(:query_type) || :name
      result = cached_get('api/user/other_info', query_type => query_value)

      if result['ret'].to_i.zero? && result['data']
        user = UserDecorator.decorate(result['data'])
        publish_user(user)
      else
        $spider_logger.error log(%{Failed to gather profile of user "#{query_type}:#{query_value}"})
      end
      false
    end

    private

    def random_keyword
      @keywords ||= MultiJson.load(File.read(ENV['DICT_DATA_JSON_PATH']))['keywords_queue']
      word = @keywords.sample
      @keywords.delete(word)
    end

    def publish_user(user)
      $spider_logger.info log(%{Publishing user "#{user['name']}" openid: #{user['openid']}})
      PersonWorker.perform_async(
        target_source: 'tencent',
        target_id: user['openid'],
        target_name: user['name'],
        birth_year: user['birth_year'],
        gender: user['gender'],
        city: user['city']
      )
    end
  end
end
