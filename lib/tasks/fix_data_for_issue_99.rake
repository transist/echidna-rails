desc 'Fix data for issue 99'
task fix_data_for_issue_99: :environment do
  puts 'Dropping tweets and stats...'
  Tweet.collection.drop
  DailyStat.collection.drop
  HourlyStat.collection.drop

  puts 'Rebuilding indexes...'
  Rake::Task['db:mongoid:remove_indexes'].execute
  Rake::Task['db:mongoid:create_indexes'].execute

  puts 'Renaming gender both to unknown...'
  Person.where(gender: 'both').update_all(gender: 'unknown')
  Group.where(gender: 'both').update_all(gender: 'unknown')
  Panel.where(gender: 'both').update_all(gender: 'unknown')

  puts 'Adding city unknown...'
  city_unknown = City.find_or_create_by(name: 'Unknown', tier: 'Tier unknown')

  Person.where(city_id: nil).update_all(city_id: city_unknown.id)

  puts 'Creating missing groups...'
  Group.create_groups!

  puts 'Clearing people groups and panels groups relations...'
  Group.all.unset :person_ids
  Group.update_all panel_ids: []
  Person.update_all group_ids: []
  Panel.update_all group_ids: []

  puts 'Rebuilding people groups relations...'
  groups_count = Group.count
  i = 0
  Group.all.batch_size(Group.count).each do |group|
    criteria = if group.start_birth_year.nil? && group.end_birth_year.nil?
                 Person.all
               else
                 Person.where(
                   :birth_year.gte => group.start_birth_year,
                   :birth_year.lte => group.end_birth_year
                 )
               end

    criteria = if group.gender.nil?
                 criteria
               else
                 criteria.where(gender: group.gender)
               end

    criteria = if group.city_id.nil?
                 criteria
               else
                 criteria.where(city_id: group.city_id)
               end

    criteria.push(:group_ids, group.id)

    print "\r%d/%d groups processed, completed %g%%." % [i, groups_count, i / groups_count.to_f * 100]
    i += 1
  end
  puts

  puts 'Rebuilding panels groups relations...'
  Panel.all.each do |panel|
    panel.save
  end
end
