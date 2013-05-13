require 'spec_helper'

describe HourlyStat do
  it { should belong_to :group }

  describe ".top_trends" do
    before do
      Timecop.freeze(Time.now.change(hour: 10))
      prepare_hourly_stats
    end

    after do
      Timecop.return
    end

    it "returns word1, word3 and word2 for group 1" do
      expect(HourlyStat.top_trends(1)).to eq [
        {word: "word2", z_score: 1.4804519606800843},
        {word: "word1", z_score: 1.4804519606800841},
        {word: "word3", z_score: 1.4804519606800841}
      ]
    end

    it "returns nothing for group 2" do
      expect(HourlyStat.top_trends(2)).to be_empty
    end

    it "checks history for only 1 hour" do
      expect(HourlyStat.top_trends(1, hours: 1)).to eq [
        {word: "word1", z_score: 0},
        {word: "word2", z_score: 0},
        {word: "word3", z_score: 0}
      ]
    end

    it "query 2 days data" do
      expect(HourlyStat.top_trends(1, hours: 20)).to eq [
        {word: "word1", z_score: 1.429954466009161},
        {word: "word3", z_score: 1.4226184910682367},
        {word: "word2", z_score: 1.3661642830588334}
      ]
    end
  end
end
