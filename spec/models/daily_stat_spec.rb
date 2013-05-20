require 'spec_helper'

describe DailyStat do
  it { should belong_to :group }
  it { should have_field(:stats).of_type(Array) }
  it { should validate_uniqueness_of(:word).scoped_to([:group, :date]) }

  context 'default value of stats' do
    context 'when the month of date has 31 days' do
      it 'has 31 elements' do
        daily_stat = create(:daily_stat, date: Date.parse('2013-05-16'))
        expect(daily_stat.stats.size).to eq(31)
      end

      it 'init count to 0 for all days' do
        daily_stat = create(:daily_stat, date: Date.parse('2013-05-16'))
        daily_stat.stats.each do |stat|
          expect(stat['count']).to eq(0)
        end
      end
    end

    context 'when the month of date has 29 days' do
      it 'has 29 elements' do
        daily_stat = create(:daily_stat, date: Date.parse('2012-02-14'))
        expect(daily_stat.stats.size).to eq(29)
      end

      it 'init count to 0 for all days' do
        daily_stat = create(:daily_stat, date: Date.parse('2012-02-14'))
        daily_stat.stats.each do |stat|
          expect(stat['count']).to eq(0)
        end
      end
    end
  end

  describe '.record' do
    let(:word) { 'Zerg' }
    let(:group) { create(:group) }
    let(:dates) { [Date.parse('2013-03-01'), Date.parse('2013-04-16'), Date.parse('2013-05-31')] }

    context 'when the DailyStat instance not exists' do
      it 'create an instance' do
        dates.each do |date|
          expect {
            DailyStat.record(word, group, date)
          }.to change(DailyStat, :count).by(1)
        end
      end

      it 'increment count for the date' do
        dates.each do |date|
          DailyStat.record(word, group, date)
          daily_stat = DailyStat.where(date: date.beginning_of_month).first
          expect(daily_stat.stats.find {|stat| stat['day'] == date.mday }['count']).to eq(1)
        end
      end
    end

    context 'when the DailyStat instance already exists' do
      before do
        dates.each {|date| DailyStat.record(word, group, date) }
      end

      it 'do not create new instance' do
        dates.each do |date|
          expect {
            DailyStat.record(word, group, date)
          }.to_not change(DailyStat, :count)
        end
      end

      it 'increment count for the date' do
        dates.each do |date|
          DailyStat.record(word, group, date)
          daily_stat = DailyStat.where(date: date.beginning_of_month).first
          expect(daily_stat.stats.find {|stat| stat['day'] == date.mday }['count']).to eq(2)
        end
      end
    end
  end

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
      Timecop.freeze(Time.now.change(day: 10))
      prepare_daily_stats(panel)
    end

    after do
      Timecop.return
    end

    it "returns 中国, 日本 and 美国" do
      expect(DailyStat.top_trends(panel)).to eq [
        {word: "美国", z_score: 1.4804519606800843},
        {word: "中国", z_score: 1.4804519606800841},
        {word: "日本", z_score: 1.4804519606800841}
      ]
    end

    it "returns nothing for other panel" do
      expect(DailyStat.top_trends(other_panel)).to be_empty
    end

    it "checks history for only 1 day" do
      expect(DailyStat.top_trends(panel, days: 1)).to eq [
        {word: "中国", z_score: 0},
        {word: "美国", z_score: 0},
        {word: "日本", z_score: 0}
      ]
    end

    it "returns only 2 words" do
      expect(DailyStat.top_trends(panel, limit: 2)).to eq [
        {word: "美国", z_score: 1.4804519606800843},
        {word: "中国", z_score: 1.4804519606800841}
      ]
    end

    it "query 2 days data" do
      expect(DailyStat.top_trends(panel, days: 20)).to eq [
        {word: "中国", z_score: 1.3851386144545532},
        {word: "日本", z_score: 1.356305321707554},
        {word: "美国", z_score: 1.1815597860975298}
      ]
    end
  end
end
