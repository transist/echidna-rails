require 'spec_helper'

describe Tweet do
  it { should validate_presence_of :content }
  it { should belong_to :person }

  let(:tweet) { create(:tweet) }

  describe '#init_words' do
    it 'segement the content to words' do
      tweet
      Rseg.expects(:segment).with(tweet.content).
        returns(%w(We sense a soul in search of answers))

      tweet.send :init_words
    end

    it 'rejct the stop words' do
      words = Rseg.segment(tweet.content)
      Echidna::Stopwords.expects(:reject).with(words).
        returns(%w(We sense soul search answers))

      tweet.send :init_words
    end
  end

  describe '#update_stats' do
    before do
      Echidna::Stopwords.stubs(:reject).returns(%w(We sense soul search answers))
      expect(tweet.person).to have(5).groups
    end

    it 'update daily stats of all words for all groups of the author' do
      %w(We sense soul search answers).each do |word|
        tweet.person.groups.each do |group|
          HourlyStat.expects(:record).with(word, group, tweet)
        end
      end

      tweet.send :update_stats
    end

    it 'update hourly stats of all words for all groups of the author' do
      %w(We sense soul search answers).each do |word|
        tweet.person.groups.each do |group|
          DailyStat.expects(:record).with(word, group, tweet)
        end
      end

      tweet.send :update_stats
    end
  end
end
