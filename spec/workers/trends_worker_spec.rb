require 'spec_helper'

describe TrendsWorker do
  let(:panel) { create :panel }
  let(:user) { create :user }

  it "queries a daily top trends for 30 days" do
    DailyStat.expects(:top_trends).with(panel, user, days: 30)
    TrendsWorker.perform_async(panel.id.to_s, user.id.to_s, 30, "days")
  end

  it "queries a daily top trends for 7 days" do
    DailyStat.expects(:top_trends).with(panel, user, days: 7)
    TrendsWorker.perform_async(panel.id.to_s, user.id.to_s, 7, "days")
  end

  it "queries a hourly top trends for 24 hours" do
    HourlyStat.expects(:top_trends).with(panel, user, hours: 24)
    TrendsWorker.perform_async(panel.id.to_s, user.id.to_s, 24, "hours")
  end

  it "queries a hourly top trends for 7 hours" do
    HourlyStat.expects(:top_trends).with(panel, user, hours: 7)
    TrendsWorker.perform_async(panel.id.to_s, user.id.to_s, 7, "hours")
  end
end
