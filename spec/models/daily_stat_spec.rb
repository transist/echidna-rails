require 'spec_helper'

describe DailyStat do
  it { should belong_to :group }

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
    Timecop.freeze(Time.now.change(day: 10))
    prepare_daily_stats(panel)
  end

  after do
    Timecop.return
  end

  describe ".aggregate_stats" do
    it "returns words with z_scores" do
      expect(DailyStat.aggregate_stats(
        [{
          "中国" => [30, 40, 50, 60, 70, 80, 90],
          "美国" => [3, 4, 5, 6, 7, 8, 9],
          "日本" => [36, 48, 60, 72, 84, 96, 108]
        }],
        [{
          "中国" => 100, "美国" => 10, "日本" => 120
        }]
      )).to eq([
        {word: "美国", z_score: 1.4804519606800843},
        {word: "中国", z_score: 1.4804519606800841},
        {word: "日本", z_score: 1.4804519606800841}
      ])
    end

    it "returns nothing for other panel" do
      expect(DailyStat.aggregate_stats(
        [{
          "中国" => [90], "美国" => [9], "日本" => [108]
        }],
        [{
          "中国" => 100, "美国" => 10, "日本" => 120
        }]
      )).to eq([
        {word: "中国", z_score: 0},
        {word: "美国", z_score: 0},
        {word: "日本", z_score: 0}
      ])
    end

    it "aggregates multiple stats" do
      expect(DailyStat.aggregate_stats(
        [{
          "中国" => [30, 40, 50, 60, 70, 80, 90],
          "美国" => [3, 4, 5, 6, 7, 8, 9],
          "日本" => [36, 48, 60, 72, 84, 96, 108]
        },
        {
          "中国" => [30, 40, 50, 60, 70, 80, 90],
          "美国" => [3, 4, 5, 6, 7, 8, 9],
          "日本" => [36, 48, 60, 72, 84, 96, 108]
        }],
        [{
          "中国" => 100, "美国" => 10, "日本" => 120
        }, {
          "中国" => 100, "美国" => 10, "日本" => 120
        }]
      )).to eq([
        {word: "美国", z_score: 1.4804519606800843},
        {word: "中国", z_score: 1.4804519606800841},
        {word: "日本", z_score: 1.4804519606800841}
      ])
    end
  end

  describe ".word_stats" do
    it "returns 中国, 日本 and 美国 stats" do
      stats = DailyStat.words_stats(group1.id, current_time: Time.now, start_time: 7.days.ago)
      expect(stats).to eq({
        history_stats: {
          "中国" => [30, 40, 50, 60, 70, 80, 90],
          "美国" => [3, 4, 5, 6, 7, 8, 9],
          "日本" => [36, 48, 60, 72, 84, 96, 108]
        },
        current_stats: {
          "中国" => 100, "美国" => 10, "日本" => 120
        }
      })
    end

    it "returns nothing for non existent group" do
      stats = DailyStat.words_stats(-1, current_time: Time.now, start_time: 7.days.ago)
      expect(stats).to eq({history_stats: {}, current_stats: {}})
    end

    it "returns stats for only 1 day" do
      stats = DailyStat.words_stats(group1.id, current_time: Time.now, start_time: 1.day.ago)
      expect(stats).to eq({
        history_stats: {
          "中国" => [90], "美国" => [9], "日本" => [108]
        },
        current_stats: {
          "中国" => 100, "美国" => 10, "日本" => 120
        }
      })
    end
  end
end
