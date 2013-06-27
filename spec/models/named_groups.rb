shared_context 'named groups' do

  # Named groups with general params
  Person::GENDERS.each do |gender|
    [:shanghai, :beijing, :unknown].each do |city_name|
      [[1982, 1988], [1989, 1995], [Person::BIRTH_YEAR_UNKNOWN, Person::BIRTH_YEAR_UNKNOWN]].each do |birth_years|
        group_name = 'group_%s_%s_%s_%s' % [birth_years.first, birth_years.last, gender, city_name]
        let(group_name.to_sym) {
          city = instance_variable_get('@city_%s' % city_name)
          Group.where(start_birth_year: birth_years.first,
                      end_birth_year: birth_years.last,
                      gender: gender, city_id: city.id
                     ).first
        }
      end
    end
  end

  # Named groups for "all" birth_years
  Person::GENDERS.each do |gender|
    [:shanghai, :beijing, :unknown].each do |city_name|
      group_name = 'group_all_%s_%s' % [gender, city_name]
      let(group_name.to_sym) {
        city = instance_variable_get('@city_%s' % city_name)
        Group.where(start_birth_year: nil,
                    end_birth_year: nil,
                    gender: gender, city_id: city.id
                   ).first
      }
    end
  end

  # Named groups for "all" genders
  [:shanghai, :beijing, :unknown].each do |city_name|
    [[1982, 1988], [1989, 1995], [Person::BIRTH_YEAR_UNKNOWN, Person::BIRTH_YEAR_UNKNOWN]].each do |birth_years|
      group_name = 'group_%s_%s_all_%s' % [birth_years.first, birth_years.last, city_name]
      let(group_name.to_sym) {
        city = instance_variable_get('@city_%s' % city_name)
        Group.where(start_birth_year: birth_years.first,
                    end_birth_year: birth_years.last,
                    gender: nil, city_id: city.id
                   ).first
      }
    end
  end

  # Named groups for "all" cities
  Person::GENDERS.each do |gender|
    [[1982, 1988], [1989, 1995], [Person::BIRTH_YEAR_UNKNOWN, Person::BIRTH_YEAR_UNKNOWN]].each do |birth_years|
      group_name = 'group_%s_%s_%s_all' % [birth_years.first, birth_years.last, gender]
      let(group_name.to_sym) {
        Group.where(start_birth_year: birth_years.first,
                    end_birth_year: birth_years.last,
                    gender: gender, city_id: nil
                   ).first
      }
    end
  end

  # Named groups for "all" birth years, genders, and cities, which means all people.
  let(:group_all_all_all) {
    Group.where(start_birth_year: nil, end_birth_year: nil, gender: nil, city_id: nil).first
  }
end
