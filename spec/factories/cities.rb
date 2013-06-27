# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city do
    tier 'Tier 1'
  end

  factory :city_unknown, parent: :city do
    name 'Unknown'
    tier 'Tier unknown'
  end

  factory :city_shanghai, parent: :city do
    name '上海'
  end

  factory :city_beijing, parent: :city do
    name '北京'
  end

  factory :city_guangzhou, parent: :city do
    name '广州'
  end

  factory :city_chengdu, parent: :city do
    name '成都'
    tier 'Tier 2'
  end

  factory :city_hangzhou, parent: :city do
    name '杭州'
    tier 'Tier 2'
  end

  factory :city_qingdao, parent: :city do
    name '青岛'
    tier 'Tier 2'
  end
end
