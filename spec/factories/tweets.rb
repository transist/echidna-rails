# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tweet do
    sequence(:target_id) { |n| n }
    content 'We sense a soul in search of answers.'
    association :person, factory: :person_with_groups
    posted_at { Time.now }
  end
end
