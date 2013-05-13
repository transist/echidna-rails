require 'spec_helper'

describe HourlyStat do
  it { should belong_to :group }

  describe ".top_trends" do
    let(:group1) { create :group }
    let(:group2) { create :group }
    let(:panel) {
      panel = create(:panel).tap do |panel|
        panel.groups << group1
        panel.groups << group2
      end
    }
    let(:other_panel) { create(:panel) }

    before do
      Timecop.freeze(Time.now.change(hour: 10))
      prepare_hourly_stats(panel)
    end

    after do
      Timecop.return
    end

    it "returns 中国, 日本 and 美国" do
      expect(HourlyStat.top_trends(panel)).to eq [
        {word: "美国", z_score: 1.4804519606800843},
        {word: "中国", z_score: 1.4804519606800841},
        {word: "日本", z_score: 1.4804519606800841}
      ]
    end

    it "returns nothing for other panel" do
      expect(HourlyStat.top_trends(other_panel)).to be_empty
    end

    it "checks history for only 1 hour" do
      expect(HourlyStat.top_trends(panel, hours: 1)).to eq [
        {word: "中国", z_score: 0},
        {word: "美国", z_score: 0},
        {word: "日本", z_score: 0}
      ]
    end

    it "query 2 days data" do
      expect(HourlyStat.top_trends(panel, hours: 20)).to eq [
        {word: "中国", z_score: 1.429954466009161},
        {word: "日本", z_score: 1.4226184910682367},
        {word: "美国", z_score: 1.3661642830588334}
      ]
    end
  end
end
