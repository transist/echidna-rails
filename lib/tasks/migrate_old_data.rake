desc 'Migrate data from old system'
task migrate_old_data: :environment do
  TencentAgent.delete_all
  Person.delete_all
  Group.all.unset :person_ids
  Tweet.delete_all
  DailyStat.delete_all
  HourlyStat.delete_all

  data = MultiJson.load(File.read(Rails.root.join('data.json')))

  data['agents'].each do |key, agent|
    # Reset timestamp to nil
    list_last_timestamp_map = Hash[agent['lists'].keys.map {|k| [k, nil] }]
    TencentAgent.create(agent['attributes'].merge(
      list_ids: agent['lists'].keys,
      list_last_timestamp_map: list_last_timestamp_map
    ))
  end

  data['users'].each do |user|
    person_attrs = {
      target_source: 'tencent',
      target_id: user['openid'],
      target_name: user['name'],
      birth_year: user['birth_year'],
      gender: user['gender'],
      city: user['city']
    }

    unless Person.where(
      target_source: person_attrs[:target_source],
      target_id: person_attrs[:target_id]
    ).exists?

      city = City.where(name: person_attrs.delete(:city)).first
      person = Person.create(person_attrs.merge(city: city))

      Group.all_for_person(person).each do |group|
        group.add_person(person)
      end
    end
  end

  # TODO: Migrate the following queues
  #
  # data[:users_tracking_queue] = $redis.lrange(TencentAgent::USERS_TRACKING_QUEUE, 0, -1)
  # data[:keywords_queue] = $redis.smembers(TencentAgent::KEYWORDS_QUEUE)
end
