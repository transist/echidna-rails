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
    before { Tweet.skip_callback(:create, :after, :update_stats) }
    let(:word) { 'Zerg' }
    let(:group) { create(:group) }
    let(:tweets) { [
      create(:tweet, posted_at: Time.parse('2013-03-14 00:20:12')),
      create(:tweet, posted_at: Time.parse('2013-04-15 12:50:02')),
      create(:tweet, posted_at: Time.parse('2013-05-16 23:32:55'))
    ] }

    context 'when the DailyStat instance not exists' do
      it 'create an instance' do
        tweets.each do |tweet|
          expect {
            DailyStat.record(word, group, tweet)
          }.to change(DailyStat, :count).by(1)
        end
      end

      it 'increment count for the date' do
        tweets.each do |tweet|
          DailyStat.record(word, group, tweet)
          daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month).first
          expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['count']).to eq(1)
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          DailyStat.record(word, group, tweet)
          daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month).first
          expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to have(1).tweet_ids
          expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to be_include tweet.id
        end
      end
    end

    context 'when the DailyStat instance already exists' do
      before do
        tweets.each { |tweet| DailyStat.record(word, group, tweet) }
      end

      it 'do not create new instance' do
        tweets.each do |tweet|
          expect {
            DailyStat.record(word, group, tweet)
          }.to_not change(DailyStat, :count)
        end
      end

      it 'increment count for the date' do
        tweets.each do |tweet|
          DailyStat.record(word, group, tweet)
          daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month).first
          expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['count']).to eq(2)
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          DailyStat.record(word, group, tweet)
          daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month).first
          expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to have(2).tweet_ids
          expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to be_include tweet.id
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
    let(:user) { create(:user) }

    before do
      Timecop.freeze(Time.now.change(day: 10))
      prepare_daily_stats(panel)
    end

    after do
      Timecop.return
    end

    it "returns 中国, 日本 and 美国" do
      expect(DailyStat.top_trends(panel, user)).to eq({
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
      expect(DailyStat.top_trends(other_panel, user)).to eq({
        positive_stats: [],
        zero_stats: [],
        negative_stats: []
      })
    end

    it "checks history for only 1 day" do
      expect(DailyStat.top_trends(panel, user, days: 1)).to eq({
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
      expect(DailyStat.top_trends(panel, user, limit: 2)).to eq({
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
      expect(DailyStat.top_trends(panel, user)).to eq({
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

    it "query 20 days data" do
      expect(DailyStat.top_trends(panel, user, days: 20)).to eq({
        positive_stats: [
          {word: "中国", z_score: 1.3851386144545532, current_stat: 200},
          {word: "日本", z_score: 1.356305321707554, current_stat: 240},
          {word: "美国", z_score: 1.1815597860975298, current_stat: 20}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.3162319466963037, current_stat: 120}
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
    let(:tweet1) { create :tweet, posted_at: 1.day.ago }
    let(:tweet2) { create :tweet, posted_at: 2.days.ago }
    let(:tweet3) { create :tweet, posted_at: 3.days.ago }

    before do
      Tweet.skip_callback(:create, :after, :update_stats)

      DailyStat.record('foo', group1, tweet1)
      DailyStat.record('foo', group2, tweet2)
      DailyStat.record('foo', group1, tweet3)
      DailyStat.record('foo', other_group, tweet1)
      DailyStat.record('bar', other_group, tweet2)
    end

    it "returns all tweets" do
      expect(DailyStat.tweets(panel, 'foo')).to have(3).tweets
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to eq [tweet3.target_id, tweet1.target_id, tweet2.target_id]
    end

    it "returns tweets only contain word" do
      expect(DailyStat.tweets(other_panel, 'bar')).to have(1).tweets
      expect(DailyStat.tweets(other_panel, 'bar').map { |stat| stat[:target_id] }).to eq [tweet2.target_id]
    end

    it "returns tweets only belong to a panel" do
      expect(DailyStat.tweets(other_panel, 'foo')).to have(1).tweets
      expect(DailyStat.tweets(other_panel, 'foo').map { |stat| stat[:target_id] }).to eq [tweet1.target_id]
    end

    it "returns tweets only after time" do
      expect(DailyStat.tweets(panel, 'foo', days: 2)).to have(2).tweets
      expect(DailyStat.tweets(panel, 'foo', days: 2).map { |stat| stat[:target_id] }).to eq [tweet1.target_id, tweet2.target_id]
    end
  end
end
