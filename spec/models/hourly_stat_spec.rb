require 'spec_helper'

describe HourlyStat do
  context ".top_trends" do
    before do
      Timecop.freeze(Time.now.change(hour: 10))
      prepare_hourly_stats
    end

    after do
      Timecop.return
    end

    it "returns word1, word3 and word2 for group 1" do
      expect(HourlyStat.top_trends(1).map { |stat| stat[0] }).to eq %w(word2 word1 word3)
    end

    it "returns nothing for group 2" do
      expect(HourlyStat.top_trends(2)).to be_empty
    end

    it "checks history for only 1 hour" do
      expect(HourlyStat.top_trends(1, hours: 1).map { |stat| stat[0] }).to eq %w(word1 word2 word3)
    end

    it "query 2 days data" do
      expect(HourlyStat.top_trends(1, hours: 20).map { |stat| stat[0] }).to eq %w(word1 word3 word2)
    end
  end
end
