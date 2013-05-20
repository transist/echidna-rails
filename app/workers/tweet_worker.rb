class TweetWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :spider

  def perform(tweet_attrs)
    target_id = tweet_attrs.delete('target_person_id')
    person = Person.where(
      target_source: tweet_attrs.delete('target_source'),
      target_id: target_id
    ).first

    if person.nil?
      TencentAgent.first.sample_user(target_id, query_type: :fopenid)
    end

    person.tweets.create(tweet_attrs)
  end
end
