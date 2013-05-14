require 'spec_helper'

describe TrendsWorker do
  let(:panel) { create :panel }

  it "queries a daily top trends for 30 days" do
    DailyStat.expects(:top_trends).with(panel, days: 30)
    TrendsWorker.perform_async(panel.id, 30, "days")
  end

  it "queries a daily top trends for 7 days" do
    DailyStat.expects(:top_trends).with(panel, days: 7)
    TrendsWorker.perform_async(panel.id, 7, "days")
  end

  it "queries a hourly top trends for 24 hours" do
    HourlyStat.expects(:top_trends).with(panel, hours: 24)
    TrendsWorker.perform_async(panel.id, 24, "hours")
  end

  it "queries a hourly top trends for 7 hours" do
    HourlyStat.expects(:top_trends).with(panel, hours: 7)
    TrendsWorker.perform_async(panel.id, 7, "hours")
  end
end
