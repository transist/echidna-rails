require 'spec_helper'

describe HourlyStat do
  it { should belong_to :group }

  let(:group) { create :group }
  let(:other_group) { create :group }

  before do
    Timecop.freeze(Time.now.change(hour: 10))
    prepare_hourly_stats(group)
  end

  after do
    Timecop.return
  end

  describe ".word_stats" do
    it "returns 中国, 日本 and 美国 stats" do
      stats = HourlyStat.words_stats(group.id, current_time: Time.now, start_time: 7.hours.ago)
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

    it "returns nothing for other group" do
      stats = HourlyStat.words_stats(other_group.id, current_time: Time.now, start_time: 7.hours.ago)
      expect(stats).to eq({history_stats: {}, current_stats: {}})
    end

    it "returns stats for only 1 hour" do
      stats = HourlyStat.words_stats(group.id, current_time: Time.now, start_time: 1.hour.ago)
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
