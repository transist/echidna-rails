require 'spec_helper'

describe TweetWorker do
  before do
    seed_groups
    create(:person, target_source: 'tencent', target_id: '5a67a4b2818d0651ad5b70091ad6c73a')
  end

  let(:tweet_attrs) { {
    target_source: 'tencent',
    target_person_id: '5a67a4b2818d0651ad5b70091ad6c73a',
    target_id: 42424242,
    content: 'We sense a soul in search of answers.',
    posted_at: 1368433820
  } }

  describe '#perform' do
    it 'save the tweet' do
      expect {
        TweetWorker.perform_async(tweet_attrs)
      }.to change(Tweet, :count).by(1)
    end

    it 'segement the tweet' do
      Segment.expects(:get).with(tweet_attrs[:content]).
        returns(%w(We sense a soul in search of answers))
      TweetWorker.perform_async(tweet_attrs)
    end

    it 'filter the stop words' do
      words = Segment.get(tweet_attrs[:content])
      Stopword.expects(:filter).with(words)
      TweetWorker.perform_async(tweet_attrs)
    end

    it 'update daily stats of all words for all groups of the author' do
    end

    it 'update hourly stats of all words for all groups of the author' do
    end
  end
end
