# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    gender 'female'
    groups { create_list(:group, 5) }
  end

  factory :person_shanghai_female_1999, parent: :person do
    birth_year 1999
    city { City.where(name: '上海').first || create(:city_shanghai) }
  end
end
