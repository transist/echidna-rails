module Support
  module Groups
    def seed_groups
      @city_shanghai = create(:city_shanghai)
      @city_beijing = create(:city_beijing)
      @city_guangzhou = create(:city_guangzhou)
      @city_chengdu = create(:city_chengdu)
      @city_hangzhou = create(:city_hangzhou)
      @city_qingdao = create(:city_qingdao)
      @city_unknown = create(:city_unknown)

      [*Person::GENDERS, nil].each do |gender|
        [*City.all.map(&:id), nil].each do |city_id|
          [*Person::BIRTH_YEARS, [nil, nil]].each do |birth_year|
            Group.create!(
              gender: gender,
              city_id: city_id,
              start_birth_year: birth_year.first,
              end_birth_year: birth_year.last
            )
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Support::Groups
end
