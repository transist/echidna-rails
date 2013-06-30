require 'spec_helper'

describe DailyStat do
  it { should belong_to :group }
  it { should have_field(:stats).of_type(Array) }

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
    let(:tweets) { [
      create(:tweet, posted_at: Time.parse('2013-03-14 00:20:12')),
      create(:tweet, posted_at: Time.parse('2013-04-15 12:50:02')),
      create(:tweet, posted_at: Time.parse('2013-05-16 23:32:55'))
    ] }

    context 'when the DailyStat instances not exist' do
      it 'create instances' do
        tweets.each do |tweet|
          expect {
            DailyStat.record(tweet)
          }.to change(DailyStat, :count).by(tweet.words.size * tweet.person.groups.count)
        end
      end

      it 'increment count for the date' do
        tweets.each do |tweet|
          DailyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month, group: group, word: word).first
              expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['count']).to eq(1)
            end
          end
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          DailyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month, group: group, word: word).first
              expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to have(1).tweet_ids
              expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to be_include tweet.id
            end
          end
        end
      end
    end

    context 'when the DailyStat instances already exist' do
      before do
        tweets.each { |tweet| DailyStat.record(tweet) }
      end

      it 'do not create new instances' do
        tweets.each do |tweet|
          expect {
            DailyStat.record(tweet)
          }.to_not change(DailyStat, :count)
        end
      end

      it 'increment count for the date' do
        tweets.each do |tweet|
          DailyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month, group: group, word: word).first
              expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['count']).to eq(2)
            end
          end
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          DailyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month, group: group, word: word).first
              expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to have(2).tweet_ids
              expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to be_include tweet.id
            end
          end
        end
      end
    end
  end

  describe '.remove' do
    before { Tweet.skip_callback(:create, :after, :update_stats) }
    let(:word) { 'Zerg' }
    let(:group) { create(:group) }
    let(:tweets) { [
      create(:tweet, posted_at: Time.parse('2013-03-14 00:20:12')),
      create(:tweet, posted_at: Time.parse('2013-04-15 12:50:02')),
      create(:tweet, posted_at: Time.parse('2013-05-16 23:32:55'))
    ] }

    before do
      tweets.each { |tweet| DailyStat.record(word, group, tweet) }
    end

    it 'increment count for the date' do
      tweets.each do |tweet|
        DailyStat.remove(word, group, tweet)
        daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month).first
        expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['count']).to eq(0)
      end
    end

    it 'add tweet_id' do
      tweets.each do |tweet|
        DailyStat.remove(word, group, tweet)
        daily_stat = DailyStat.where(date: tweet.posted_at.beginning_of_month).first
        expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).to have(0).tweet_ids
        expect(daily_stat.stats.find {|stat| stat['day'] == tweet.posted_at.mday }['tweet_ids']).not_to be_include tweet.id
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
          {word: "美国", z_score: 1.5302264278053699, current_stat: 20},
          {word: "中国", z_score: 1.5302264278053697, current_stat: 182},
          {word: "日本", z_score: 1.5302264278053697, current_stat: 218}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.5302264278053699, current_stat: 128}
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
      expect(DailyStat.top_trends(panel, user, days: 2)).to eq({
        positive_stats: [],
        zero_stats: [
          {word: "日本", z_score: 0, current_stat: 218},
          {word: "中国", z_score: 0, current_stat: 182},
          {word: "朝鲜", z_score: 0, current_stat: 128},
          {word: "美国", z_score: 0, current_stat: 20},
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: []
      })
    end

    it "returns only 2 words" do
      expect(DailyStat.top_trends(panel, user, limit: 2)).to eq({
        positive_stats: [
          {word: "美国", z_score: 1.5302264278053699, current_stat: 20},
          {word: "中国", z_score: 1.5302264278053697, current_stat: 182}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.5302264278053699, current_stat: 128}
        ]
      })
    end

    it "filter 中国 as stopword" do
      user.add_stopword '中国'
      expect(DailyStat.top_trends(panel, user)).to eq({
        positive_stats: [
          {word: "美国", z_score: 1.5302264278053699, current_stat: 20},
          {word: "日本", z_score: 1.5302264278053697, current_stat: 218}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.5302264278053699, current_stat: 128}
        ]
      })
    end

    it "query 20 days data" do
      expect(DailyStat.top_trends(panel, user, days: 20)).to eq({
        positive_stats: [
          {word: "中国", z_score: 1.3112075204653202, current_stat: 182},
          {word: "日本", z_score: 1.25724689216797, current_stat: 218},
          {word: "美国", z_score: 0.9886297529124048, current_stat: 20}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.1878447288148373, current_stat: 128}
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
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet1.target_id
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet2.target_id
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet3.target_id
    end

    it "returns tweets only contain word" do
      expect(DailyStat.tweets(other_panel, 'bar')).to have(1).tweets
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet2.target_id
    end

    it "returns tweets only belong to a panel" do
      expect(DailyStat.tweets(other_panel, 'foo')).to have(1).tweets
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet1.target_id
    end

    it "returns tweets only after time" do
      expect(DailyStat.tweets(panel, 'foo', days: 2)).to have(2).tweets
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet1.target_id
      expect(DailyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet2.target_id
    end
  end
end
