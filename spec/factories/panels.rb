# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :panel do
    sequence(:name) { |n| "Panel #{n}" }
    age_ranges []
  end
end
