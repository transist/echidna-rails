class TencentAgent
  module UsersTracking
    extend ActiveSupport::Concern

    TRACK_LIMIT_PER_REQUEST = 8
    TRACK_WAIT = 0.2

    module ClassMethods
      def track_users
        info "Tracking users..."

        Person.where(tracked: false).each_slice(TRACK_LIMIT_PER_REQUEST) do |people|

          remaining_people = people
          begin
            agent = TencentAgent.available_for_tracking_users.first
            if agent
              remaining_people = agent.track(remaining_people)
            else
              raise TencentError, 'Need more agents to track users'
            end
          end until remaining_people.empty?
        end

        info "Finished users tracking"
      rescue TencentError => e
        error "Aborted users tracking: #{e.message}"
      rescue => e
        log_unexpected_error(e)
      end
    end

    def track(people)
      remaining_people = people
      tencent_lists.available.each do |list|
        remaining_people = list.track(remaining_people)
        sleep TRACK_WAIT
        break if remaining_people.empty?
      end

      unless remaining_people.empty?
        mark_as_unavailable_for_tracking_users
        sync_lists
      end

      remaining_people
    end
  end
end
