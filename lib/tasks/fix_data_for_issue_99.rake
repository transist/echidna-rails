desc 'Fix data for issue 99'
task fix_data_for_issue_99: :environment do
  Person.where(gender: 'both').update_all(gender: 'unknown')
  Group.where(gender: 'both').update_all(gender: 'unknown')
  Panel.where(gender: 'both').update_all(gender: 'unknown')

  city_unknown = City.find_or_create_by(name: 'Unknown', tier: 'Tier unknown')

  Person.where(city_id: nil).update_all(city_id: city_unknown.id)

  Group.create_groups!
end
