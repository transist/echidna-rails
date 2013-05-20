class TweetWorker
  include Sidekiq::Worker

  def perform(tweet_attrs)
    person = Person.where(
      target_source: tweet_attrs.delete('target_source'),
      target_id: tweet_attrs.delete('target_person_id')
    ).first
    
    if person.nil?
      TencentAgent.all.first.sample_user(target_id, query_type: :fopenid)
    end
    
    person.tweets.create(tweet_attrs)
  end
end
