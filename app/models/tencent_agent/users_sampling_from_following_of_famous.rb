class TencentAgent
  module UsersSamplingFromFollowingOfFamous
    extend ActiveSupport::Concern

    FOLLOWINGS_PAGE_LIMIT = 30
    SAMPLE_WAIT = 0.2

    def sample_users_from_following_of_famous
      info 'Sampling users from followings of famous...'

      Person.where(:seed_level.lte => 3, :all_followings_sampled.ne => true).
        order_by(seed_level: :asc).limit(100).each do |seed_person|

        info %{Fetching followings of seed user "#{seed_person.target_name}", seed level #{seed_person.seed_level}}
        page = 1

        loop do
          offset = (page - 1) * FOLLOWINGS_PAGE_LIMIT
          result = get('api/friends/user_idollist', fopenid: seed_person.target_id,
              reqnum: FOLLOWINGS_PAGE_LIMIT, startindex: offset, mode: 1)

          if result['ret'].to_i.zero?

            unless result['data']['info']
              info %{Seed user "#{seed_person.target_name}" don't have followings}
              seed_person.all_followings_sampled!
              break
            end

            result['data']['info'].each do |following|
              sample_user(following['openid'],
                          seed_person_id: seed_person.id.to_s,
                          seed_level: seed_person.seed_level + 1
                          )
            end

            if result['data']['hasnext'].to_i == 1
              info %{No more followings for seed user "#{seed_person.target_name}"}
              seed_person.all_followings_sampled!
              break
            end

          else
            error %{Failed to fetch followings of user "#{seed_person.target_name}": #{result['msg']}}
            break
          end

          page += page
          sleep SAMPLE_WAIT
        end
      end

      info 'Finished sample users from followings of famous'

    rescue Error => e
      error "Aborted sample users from followings of famous: #{e.message}"
    rescue => e
      log_unexpected_error(e)
    end
  end
end
