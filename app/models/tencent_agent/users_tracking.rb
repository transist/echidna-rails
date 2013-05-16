class TencentAgent
  module UsersTracking
    extend ActiveSupport::Concern

    USERS_TRACKING_LIST_PREFIX = 'UTL'

    def track_users(user_names)
      $spider_logger.info log('Tracking users...')

      # Tencent Weibo's add_to_list API accept at most 8 user names per request.
      
      if user_names.count > 8
        user_names.slice!(8)
        $spider_logger.warn log("Tencent Weibo's add_to_list API accept at most 8 user names per request.") 
      end

      unless user_names.empty?
        begin
          track_users_by_list(user_names)
        rescue
          # TODO: figure out a better way to rescue track user failure.
          $spider_logger.error "Added to list fail"
        end

        sleep SLEEP_WAIT
      end

      $spider_logger.info log('Finished users tracking')
    rescue Error => e
      $spider_logger.error log("Aborted users tracking: #{e.message}")
    rescue => e
      log_unexpected_error(e)
    end

    private
    def latest_users_tracking_list_id
      list_ids.last || create_list(next_users_tracking_list_name)['listid']
    end

    def next_users_tracking_list_name
      # Humanized 1 based name sequence
      # The maximized allowd name length is 13
      '%s_%09d' % [USERS_TRACKING_LIST_PREFIX, list_ids.count + 1]
    end

    def create_list(list_name)
      result = post('api/list/create', name: list_name, access: 1)
      if result['ret'].to_i.zero?
        add_list_to_users_tracking_lists(result['data'])
        $spider_logger.info log(%{Created list "#{list_name}"})
        result['data']

      elsif result['ret'].to_i == 4 and result['errcode'].to_i == 98
        update_attribute :full_with_lists, true
        raise Error, 'List create limitation reached'

      else
        raise Error.new(%{Failed to create list "#{list_name}"}, result)
      end
    end

    def add_list_to_users_tracking_lists(list)
      list_ids << list['listid'] 
      save
    end

    def track_users_by_list(user_names)
      result = post('api/list/add_to_list', names: user_names.join(','), listid: latest_users_tracking_list_id)
      if result['ret'].to_i.zero?
        $spider_logger.info log(%{Tracked users "#{user_names.join(',')}" by list})

      else
        # List limitation of maximized members reached
        if result['ret'].to_i == 5 and result['errcode'].to_i == 98
          create_list(next_users_tracking_list_name)
        end

        raise Error.new(%{Failed to track users "#{user_names.join(',')}" by list}, result)
      end
    end

    def self.get_agent_with_capacity
      TencentAgent.all.each{|agent| break agent unless agent[:full_with_lists]}
    end
  end
end
