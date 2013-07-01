require 'spec_helper'

describe HourlyStat do
  it { should belong_to :group }
  it { should have_field(:stats).of_type(Array).with_default_value_of(
    (0..23).map {|n| {hour: n, count: 0} }
  ) }

  describe '.record' do
    before { Tweet.skip_callback(:create, :after, :update_stats) }
    let(:tweets) { [
      create(:tweet, posted_at: Time.parse('2013-05-14 00:20:12')),
      create(:tweet, posted_at: Time.parse('2013-05-15 12:50:02')),
      create(:tweet, posted_at: Time.parse('2013-05-16 23:32:55'))
    ] }

    context 'when the HourlyStat instances not exists' do
      it 'create instances' do
        tweets.each do |tweet|
          expect {
            HourlyStat.record(tweet)
          }.to change(HourlyStat, :count).by(tweet.words.size * tweet.person.groups.size)
        end
      end

      it 'increment count for the hour' do
        tweets.each do |tweet|
          HourlyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date, group: group, word: word).first
              expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['count']).to eq(1)
            end
          end
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          HourlyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date, group: group, word: word).first
              expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to have(1).tweet_ids
              expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to be_include tweet.id
            end
          end
        end
      end
    end

    context 'when the HourlyStat instances already exists' do
      before do
        tweets.each { |tweet| HourlyStat.record(tweet) }
      end

      it 'do not create new instances' do
        tweets.each do |tweet|
          expect {
            HourlyStat.record(tweet)
          }.to_not change(HourlyStat, :count)
        end
      end

      it 'increment count for the hour' do
        tweets.each do |tweet|
          HourlyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date, group: group, word: word).first
              expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['count']).to eq(2)
            end
          end
        end
      end

      it 'add tweet_id' do
        tweets.each do |tweet|
          HourlyStat.record(tweet)

          tweet.words.each do |word|
            tweet.person.groups.each do |group|
              hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date, group: group, word: word).first
              expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to have(2).tweet_ids
              expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to be_include tweet.id
            end
          end
        end
      end
    end
  end

  describe '.record' do
    before { Tweet.skip_callback(:create, :after, :update_stats) }
    let(:word) { 'Zerg' }
    let(:group) { create :group }
    let(:tweets) { [
      create(:tweet, posted_at: Time.parse('2013-05-14 00:20:12')),
      create(:tweet, posted_at: Time.parse('2013-05-15 12:50:02')),
      create(:tweet, posted_at: Time.parse('2013-05-16 23:32:55'))
    ] }

    before do
      tweets.each { |tweet| HourlyStat.record(word, group, tweet) }
    end

    it 'decrement count for the hour' do
      tweets.each do |tweet|
        HourlyStat.remove(word, group, tweet)
        hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date).first
        expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['count']).to eq(0)
      end
    end

    it 'remove tweet_id' do
      tweets.each do |tweet|
        HourlyStat.remove(word, group, tweet)
        hourly_stat = HourlyStat.where(date: tweet.posted_at.to_date).first
        expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).to have(0).tweet_ids
        expect(hourly_stat.stats.find {|stat| stat['hour'] == tweet.posted_at.hour }['tweet_ids']).not_to be_include tweet.id
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
      expect(HourlyStat.top_trends(other_panel, user)).to eq({
        positive_stats: [],
        zero_stats: [],
        negative_stats: []
      })
    end

    it "checks history for only 1 hour" do
      expect(HourlyStat.top_trends(panel, user, hours: 2)).to eq({
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
      expect(HourlyStat.top_trends(panel, user, limit: 2)).to eq({
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
      expect(HourlyStat.top_trends(panel, user)).to eq({
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

    it "query 20 hours data" do
      expect(HourlyStat.top_trends(panel, user, hours: 20)).to eq({
        positive_stats: [
          {word: "中国", z_score: 1.424363548200698, current_stat: 182},
          {word: "日本", z_score: 1.4076995594824548, current_stat: 218},
          {word: "美国", z_score: 1.293743079435168, current_stat: 20}
        ],
        zero_stats: [
          {word: "韩国", z_score: 0.0, current_stat: 2}
        ],
        negative_stats: [
          {word: "朝鲜", z_score: -1.3834610202106223, current_stat: 128}
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
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet1.target_id
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet2.target_id
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet3.target_id
    end

    it "returns tweets only contain word" do
      expect(HourlyStat.tweets(other_panel, 'bar')).to have(1).tweets
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet2.target_id
    end

    it "returns tweets only belong to a panel" do
      expect(HourlyStat.tweets(other_panel, 'foo')).to have(1).tweets
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet1.target_id
    end

    it "returns tweets only after time" do
      expect(HourlyStat.tweets(panel, 'foo', hours: 2)).to have(2).tweets
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet1.target_id
      expect(HourlyStat.tweets(panel, 'foo').map { |stat| stat[:target_id] }).to be_include tweet2.target_id
    end
  end
end
