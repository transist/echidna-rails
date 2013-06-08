class TencentAgent
  module UsersTracking
    extend ActiveSupport::Concern

    USERS_TRACKING_LIST_PREFIX = 'UTL'
    TRACK_WAIT = 0.2

    included do
      def self.get_agent_with_capacity
        TencentAgent.where(full_with_lists: false).first
      end
    end

    def track_users
      info "Tracking users..."

      Person.where(tracked: false).each_slice(8) do |people|
        track_users_by_list(people)
        sleep TRACK_WAIT
      end

      info "Finished users tracking"
    rescue Error => e
      error "Aborted users tracking: #{e.message}"
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
      info "Create list result #{result}"
      if result['ret'].to_i.zero?
        add_list_to_users_tracking_lists(result['data'])
        info %{Created list "#{list_name}"}
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

    def track_users_by_list(people)
      user_openids = people.map(&:target_id)

      result = post('api/list/add_to_list', fopenids: user_openids.join('_'), listid: latest_users_tracking_list_id)
      if result['ret'].to_i.zero?
        people.each do |person|
          person.update_attribute :tracked, true
        end
        info %{Tracked users "#{user_openids.join(',')}" by list}

      else
        # List limitation of maximized members reached
        if result['ret'].to_i == 5 and result['errcode'].to_i == 98
          create_list(next_users_tracking_list_name)
          track_users_by_list(people)
        else
          raise Error.new(%{Failed to track users "#{user_openids.join(',')}" by list}, result)
        end
      end
    end
  end
end
