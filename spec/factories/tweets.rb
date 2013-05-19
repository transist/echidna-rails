# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tweet do
    content 'We sense a soul in search of answers.'
    person
    posted_at { Time.now }
  end
end
