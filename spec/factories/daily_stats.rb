# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :daily_stat do
    sequence(:word) {|n| "word_#{n}" }
  end
end
