desc 'Fix data for issue 99'
task fix_data_for_issue_99: :environment do
  Person.where(gender: 'both').update_all(gender: 'unknown')
  Group.where(gender: 'both').update_all(gender: 'unknown')
  Panel.where(gender: 'both').update_all(gender: 'unknown')

  city_unknown = City.find_or_create_by(name: 'Unknown', tier: 'Tier unknown')

  Person.where(city_id: nil).update_all(city_id: city_unknown.id)

  [*Person::GENDERS, nil].each do |gender|
    [*City.all.map(&:id), nil].each do |city_id|
      [*Person::BIRTH_YEARS, [nil, nil]].each do |birth_year|
        Group.create!(
          gender: gender, city_id: city_id,
          start_birth_year: birth_year.first,
          end_birth_year: birth_year.last
        )
      end
    end
  end
end
