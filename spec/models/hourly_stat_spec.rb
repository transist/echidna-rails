require 'spec_helper'

describe HourlyStat do
  it { should belong_to :group }
  it { should have_field(:stats).of_type(Array).with_default_value_of(
    (0..23).map {|n| {hour: n, count: 0} }
  ) }
  it { should validate_uniqueness_of(:word).scoped_to([:group, :date]) }

  describe '.record' do
    let(:word) { 'Zerg' }
    let(:group) { create(:group) }
    let(:times) { [
      Time.parse('2013-05-14 00:20:12'), Time.parse('2013-05-15 12:50:02'),
      Time.parse('2013-05-16 23:32:55')
    ] }

    context 'when the HourlyStat instance not exists' do
      it 'create an instance' do
        times.each do |time|
          expect {
            HourlyStat.record(word, group, time)
          }.to change(HourlyStat, :count).by(1)
        end
      end

      it 'increment count for the hour' do
        times.each do |time|
          HourlyStat.record(word, group, time)
          hourly_stat = HourlyStat.where(date: time.to_date).first
          expect(hourly_stat.stats.find {|stat| stat['hour'] == time.hour }['count']).to eq(1)
        end
      end
    end

    context 'when the HourlyStat instance already exists' do
      before do
        times.each {|time| HourlyStat.record(word, group, time) }
      end

      it 'do not create new instance' do
        times.each do |time|
          expect {
            HourlyStat.record(word, group, time)
          }.to_not change(HourlyStat, :count)
        end
      end

      it 'increment count for the hour' do
        times.each do |time|
          HourlyStat.record(word, group, time)
          hourly_stat = HourlyStat.where(date: time.to_date).first
          expect(hourly_stat.stats.find {|stat| stat['hour'] == time.hour }['count']).to eq(2)
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
