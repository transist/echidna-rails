require 'spec_helper'

describe TweetWorker do
  before do
    seed_groups
  end

  let(:tweet_attrs) { {
    target_source: 'tencent',
    target_person_id: '5a67a4b2818d0651ad5b70091ad6c73a',
    target_id: 42424242,
    content: 'We sense a soul in search of answers.',
    posted_at: 1368433820
  } }

  describe '#perform' do
    context 'user is not marked as spammer' do
      before do
        create(:person, target_source: 'tencent', target_id: '5a67a4b2818d0651ad5b70091ad6c73a')
      end
      it 'save the tweet' do
        expect {
          TweetWorker.perform_async(tweet_attrs)
        }.to change(Tweet, :count).by(1)
      end
    end

    context 'user is marked as spammer' do
      before do
        create(:person, spam: true, target_source: 'tencent', target_id: '5a67a4b2818d0651ad5b70091ad6c73a')
      end
      it "doesn't save the tweet" do
        expect {
          TweetWorker.perform_async(tweet_attrs)
        }.to_not change(Tweet, :count)
      end
    end
  end
end
