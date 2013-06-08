class TencentAgent
  module HotUsersSampling
    extend ActiveSupport::Concern

    SAMPLE_WAIT = 0.2

    def sample_hot_users
      info 'Sampling Hot Users...'

      10.times do |i|
        result = cached_get('api/trends/t', reqnum: 100, pos: i * 100)
        if result['ret'].to_i.zero?

          unless result['data']
            info "No results for pos #{i * 100}"
            break
          end

          result['data']['info'].each do |tweet|
            sample_hot_user(tweet['openid'])
          end

        else
          error 'Failed to sample hot users'
          break
        end
      end

      info 'Finished hot users gathering'

    rescue Error => e
      error "Aborted hot users gathering: #{e.message}"
    rescue => e
      log_unexpected_error(e)
    end

    private

    def sample_hot_user(user_openid)
      result = cached_get('api/user/other_info', fopenid: user_openid)

      if result['ret'].to_i.zero? && result['data']
        user = UserDecorator.decorate(result['data'])
        publish_user(user, hot: true)
      else
        error %{Failed to gather profile of hot user "#{user_openid}"}
      end
    end
  end
end
