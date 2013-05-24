class TencentAgent
  module UsersSampling
    extend ActiveSupport::Concern

    SAMPLE_WAIT = 5

    def sample_users
      info 'Sampling Users...'

      while keyword = random_keyword
        info %{Gathering first user from tweets of keyword "#{keyword}"...}
        result = cached_get('api/search/t', keyword: keyword, pagesize: 30)

        if result['ret'].to_i.zero?

          unless result['data']
            info %{No results for keyword "#{keyword}"}
            next
          end

          user_openid = result['data']['info'].first['openid']
          sample_user(user_openid)

        else
          error "Failed to gather user: #{result['msg']}"
          break
        end

        sleep SAMPLE_WAIT
      end

      warn 'No more keywords in queue for users gathering' if @keywords.count.zero?

      info 'Finished users gathering'

    rescue Error => e
      error "Aborted users gathering: #{e.message}"
    rescue => e
      log_unexpected_error(e)
    end

    def sample_user(user_openid)
      result = cached_get('api/user/other_info', fopenid: user_openid)

      if result['ret'].to_i.zero? && result['data']
        user = UserDecorator.decorate(result['data'])
        publish_user(user)
      else
        error %{Failed to gather profile of user "#{user_openid}"}
      end
      false
    end

    private

    def random_keyword
      @keywords ||= MultiJson.load(File.read(ENV['DICT_DATA_JSON_PATH']))['keywords_queue']
      word = @keywords.sample
      @keywords.delete(word)
    end

    def publish_user(user, famous: false)
      info %{Publishing user "#{user['name']}" openid: #{user['openid']}}
      PersonWorker.perform_async(
        target_source: 'tencent',
        target_id: user['openid'],
        target_name: user['name'],
        famous: famous,
        birth_year: user['birth_year'],
        gender: user['gender'],
        city: user['city']
      )
    end
  end
end
