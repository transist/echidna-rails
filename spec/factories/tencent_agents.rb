# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tencent_agent do
    name 'username'
    nick 'nickname'
    openid SecureRandom.hex(16)
  end

  factory :tencent_agent_expires_in_less_1_day, parent: :tencent_agent do
    access_token  SecureRandom.hex(16)
    refresh_token SecureRandom.hex(16)
    expires_at (Time.now + 23.hours).to_i
  end
end
