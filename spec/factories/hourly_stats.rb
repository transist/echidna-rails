# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :hourly_stat do
    sequence(:word) { |n| "word_#{n}" }
  end
end
