# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tweet do
    content 'We sense a soul in search of answers.'
    association :person, factory: :person_with_groups
    posted_at { Time.now }
  end
end
