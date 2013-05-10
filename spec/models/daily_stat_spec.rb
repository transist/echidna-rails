require 'spec_helper'

describe DailyStat do
  it { should belong_to :group }

  describe ".top_trends" do
    before do
      Timecop.freeze(Time.now.change(day: 10))
      prepare_daily_stats
    end

    after do
      Timecop.return
    end

    it "returns word1, word3 and word2 for group 1" do
      expect(DailyStat.top_trends(1).map { |stat| stat[0] }).to eq %w(word2 word1 word3)
    end

    it "returns nothing for group 2" do
      expect(DailyStat.top_trends(2)).to be_empty
    end

    it "checks history for only 1 hour" do
      expect(DailyStat.top_trends(1, days: 1).map { |stat| stat[0] }).to eq %w(word1 word2 word3)
    end

    it "query 2 days data" do
      expect(DailyStat.top_trends(1, days: 20).map { |stat| stat[0] }).to eq %w(word1 word3 word2)
    end
  end
end
