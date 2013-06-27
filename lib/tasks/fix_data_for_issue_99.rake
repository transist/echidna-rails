desc 'Fix data for issue 99'
task fix_data_for_issue_99: :environment do
  Person.where(gender: 'both').update_all(gender: 'unknown')
  Group.where(gender: 'both').update_all(gender: 'unknown')
  Panel.where(gender: 'both').update_all(gender: 'unknown')

  city_unknown = City.find_or_create_by(name: 'Unknown', tier: 'Tier unknown')

  Person.where(city_id: nil).update_all(city_id: city_unknown.id)

  Group.create_groups!

  puts 'Clearing people groups and panels groups relations...'
  Group.all.each do |group|
    group.people.clear
    group.panels.clear
  end

  puts 'Rebuilding people groups relations...'
  Person.all.each do |person|
    Group.all_for_person(person).each do |group|
      group.add_person(person)
    end
  end

  puts 'Rebuilding panels groups relations...'
  Panel.all.each do |panel|
    panel.save
  end
end
