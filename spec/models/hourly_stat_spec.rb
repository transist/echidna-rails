require 'spec_helper'

describe HourlyStat do
  it { should belong_to :group }
  it { should have_field(:stats).of_type(Array).with_default_value_of(
    (0..23).map {|n| {hour: n, count: 0} }
  ) }
  it { should validate_uniqueness_of(:word).scoped_to([:group, :date]) }

  describe '.record' do
    before { Tweet.skip_callback(:create, :after, :update_stats) }
    let(:word) { 'Zerg' }
    let(:group) { create :group }
    let(:tweets) { [
      create(:tweet, posted_at: Time.parse('2013-05-14 00:20:12')),
      create(:tweet, posted_at: Time.parse('2013-05-15 12:50:02')),
      create(:tweet, posted_at: Time.parse('2013-05-16 23:32:55'))
    ] }

    context 'when the HourlyStat instance not exists' do
      it 'create an instance' do
        tweets.each do |tweet|
          expect {
            HourlyStat.record(word, group, tweet)
          }.to change(HourlyStat, :count).by(1)
        end
      end

      it 'increment count for the hour' do
        tweets.each do |tweet|
          HourlyStat.record(word, group, tweet)
          hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date).first
          expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['count']).to eq(1)
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          HourlyStat.record(word, group, tweet)
          hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date).first
          expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to have(1).tweet_ids
          expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to be_include tweet.id
        end
      end
    end

    context 'when the HourlyStat instance already exists' do
      before do
        tweets.each { |tweet| HourlyStat.record(word, group, tweet) }
      end

      it 'do not create new instance' do
        tweets.each do |tweet|
          expect {
            HourlyStat.record(word, group, tweet)
          }.to_not change(HourlyStat, :count)
        end
      end

      it 'increment count for the hour' do
        tweets.each do |tweet|
          HourlyStat.record(word, group, tweet)
          hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date).first
          expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['count']).to eq(2)
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          HourlyStat.record(word, group, tweet)
          hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date).first
          expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to have(2).tweet_ids
          expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to be_include tweet.id
        end
      end
    end
  end

  describe ".top_trends" do
    let(:group1) { create :group }
    let(:group2) { create :group }
    let(:panel) {
      create(:panel).tap do |panel|
        panel.groups << group1
        panel.groups << group2
      end
    }
    let(:other_panel) { create(:panel) }
    let(:user) { create(:user) }

    before do
      Timecop.freeze(Time.now.change(hour: 10))
      prepare_hourly_stats(panel)
    end

    after do
      Timecop.return
    end

    it "returns 中国, 日本 and 美国" do
      expect(HourlyStat.top_trends(panel, user)).to eq({
        positive_stats: [
          {word: "美国", z_score: 1.4804519606800843, current_stat: 20},
          {word: "中国", z_score: 1.4804519606800841, current_stat: 200},
          {word: "日本", z_score: 1.4804519606800841, current_stat: 240}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.4804519606800843, current_stat: 120}
        ]
      })
    end

    it "returns nothing for other panel" do
      expect(HourlyStat.top_trends(other_panel, user)).to eq({
        positive_stats: [],
        zero_stats: [],
        negative_stats: []
      })
    end

    it "checks history for only 1 hour" do
      expect(HourlyStat.top_trends(panel, user, hours: 1)).to eq({
        positive_stats: [],
        zero_stats: [
          {word: "日本", z_score: 0, current_stat: 240},
          {word: "中国", z_score: 0, current_stat: 200},
          {word: "朝鲜", z_score: 0, current_stat: 120},
          {word: "美国", z_score: 0, current_stat: 20},
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: []
      })
    end

    it "returns only 2 words" do
      expect(HourlyStat.top_trends(panel, user, limit: 2)).to eq({
        positive_stats: [
          {word: "美国", z_score: 1.4804519606800843, current_stat: 20},
          {word: "中国", z_score: 1.4804519606800841, current_stat: 200}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.4804519606800843, current_stat: 120}
        ]
      })
    end

    it "filter 中国 as stopword" do
      user.add_stopword '中国'
      expect(HourlyStat.top_trends(panel, user)).to eq({
        positive_stats: [
          {word: "美国", z_score: 1.4804519606800843, current_stat: 20},
          {word: "日本", z_score: 1.4804519606800841, current_stat: 240}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.4804519606800843, current_stat: 120}
        ]
      })
    end

    it "query 20 hours data" do
      expect(HourlyStat.top_trends(panel, user, hours: 20)).to eq({
        positive_stats: [
          {word: "中国", z_score: 1.429954466009161, current_stat: 200},
          {word: "日本", z_score: 1.4226184910682367, current_stat: 240},
          {word: "美国", z_score: 1.3661642830588334, current_stat: 20}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.4114509547749945, current_stat: 120}
        ]
      })
    end
  end

  describe '.tweets' do
    let(:group1) { create :group }
    let(:group2) { create :group }
    let(:panel) {
      create(:panel).tap do |panel|
        panel.groups << group1
        panel.groups << group2
      end
    }
    let(:other_group) { create :group }
    let(:other_panel) {
      create(:panel).tap { |panel| panel.groups << other_group }
    }
    let(:tweet1) { create :tweet, posted_at: 1.hour.ago }
    let(:tweet2) { create :tweet, posted_at: 2.hours.ago }
    let(:tweet3) { create :tweet, posted_at: 3.hours.ago }

    before do
      Tweet.skip_callback(:create, :after, :update_stats)

      HourlyStat.record('foo', group1, tweet1)
      HourlyStat.record('foo', group2, tweet2)
      HourlyStat.record('foo', group1, tweet3)
      HourlyStat.record('foo', other_group, tweet1)
      HourlyStat.record('bar', other_group, tweet2)
    end

    it "returns all tweets" do
      expect(HourlyStat.tweets(panel, 'foo')).to have(3).tweets
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to eq [tweet3.target_id, tweet1.target_id, tweet2.target_id]
    end

    it "returns tweets only contain word" do
      expect(HourlyStat.tweets(other_panel, 'bar')).to have(1).tweets
      expect(HourlyStat.tweets(other_panel, 'bar').map { |stat| stat[:target_id] }).to eq [tweet2.target_id]
    end

    it "returns tweets only belong to a panel" do
      expect(HourlyStat.tweets(other_panel, 'foo')).to have(1).tweets
      expect(HourlyStat.tweets(other_panel, 'foo').map { |stat| stat[:target_id] }).to eq [tweet1.target_id]
    end

    it "returns tweets only after time" do
      expect(HourlyStat.tweets(panel, 'foo', hours: 2)).to have(2).tweets
      expect(HourlyStat.tweets(panel, 'foo', hours: 2).map { |stat| stat[:target_id] }).to eq [tweet1.target_id, tweet2.target_id]
    end
  end
end
