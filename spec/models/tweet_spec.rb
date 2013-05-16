require 'spec_helper'

describe Tweet do
  it { should validate_presence_of :content }
  it { should belong_to :person }

  let(:tweet) { create(:tweet) }

  describe '#extract_words' do
    it 'segement the content to words' do
      tweet
      Segment.expects(:get).with(tweet.content).
        returns(%w(We sense a soul in search of answers))

      tweet.extract_words
    end

    it 'filter the stop words' do
      words = Segment.get(tweet.content)
      Stopword.expects(:filter).with(words).
        returns(%w(We sense soul search answers))

      tweet.extract_words
    end
  end

  describe '#update_stats' do
    before do
      Stopword.stubs(:filter).returns(%w(We sense soul search answers))
    end

    it 'update daily stats of all words for all groups of the author' do
      %w(We sense soul search answers).each do |word|
        tweet.person.groups.each do |group|
          HourlyStat.expects(:record).with(word, group, tweet.posted_at)
        end
      end

      tweet.send :update_stats
    end

    it 'update hourly stats of all words for all groups of the author' do
      %w(We sense soul search answers).each do |word|
        tweet.person.groups.each do |group|
          DailyStat.expects(:record).with(word, group, tweet.posted_at.to_date)
        end
      end

      tweet.send :update_stats
    end
  end
end
