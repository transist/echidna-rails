class TweetWorker
  include Sidekiq::Worker

  def perform(tweet_attrs)
    person = Person.where(
      target_source: tweet_attrs.delete('target_source'),
      target_id: tweet_attrs.delete('target_person_id')
    ).first
    person.tweets.create(tweet_attrs)
  end
end
