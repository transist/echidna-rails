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
      # In this case actually this job will still failed, since sample_user
      # need PersonWorker to persist the person, this make us can't load person
      # here. But this job will finally successed in the future retries.
      TencentAgent.first.sample_user(target_id)
    end

    person.tweets.create(tweet_attrs)
  end
end
