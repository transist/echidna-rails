module Support
  module Groups
    def seed_groups
      create(:city_shanghai)
      create(:city_beijing)
      create(:city_guangzhou)
      create(:city_chengdu)
      create(:city_hangzhou)
      create(:city_qingdao)

      Person::GENDERS.each do |gender|
        City.all.each do |city|
          Person::BIRTH_YEARS.each do |birth_year|
            Group.create!(
              gender: gender,
              city: city,
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
