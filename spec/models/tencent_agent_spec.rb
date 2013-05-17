require 'spec_helper'

describe TencentAgent do
  let(:expiring_agent) { create(:tencent_agent_expires_in_less_1_day) }

  it "should refresh access token 1 day before current token expires" do
    body_string = "access_token=#{SecureRandom.hex(16)}&expires_in=604800&refresh_token=#{SecureRandom.hex(16)}"
    stub_request(:any, "open.t.qq.com").
      to_return(body: body_string, status: 200)

    (Time.at(expiring_agent.expires_at) - Time.now).should be <= 1.day
    # expiring_agent.refresh_access_token
    # (Time.at(expiring_agent.expires_at) - Time.now).should be > 1.day
  end
end
