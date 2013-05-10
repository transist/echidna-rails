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
      expect(DailyStat.top_trends(1)).to eq [{word: "word2", z_score: 1.4804519606800843}, {word: "word1", z_score: 1.4804519606800841}, {word: "word3", z_score: 1.4804519606800841}]
    end

    it "returns nothing for group 2" do
      expect(DailyStat.top_trends(2)).to be_empty
    end

    it "checks history for only 1 hour" do
      expect(DailyStat.top_trends(1, days: 1)).to eq [{word: "word1", z_score: 0}, {word: "word2", z_score: 0}, {word: "word3", z_score: 0}]
    end

    it "query 2 days data" do
      expect(DailyStat.top_trends(1, days: 20)).to eq [{word: "word1", z_score: 1.3851386144545532}, {word: "word3", z_score: 1.356305321707554}, {word: "word2", z_score: 1.1815597860975298}]
    end
  end
end
