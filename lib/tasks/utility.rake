desc 'Purge the tweets and stats, then reset tweets gathering progress to given days ago.'
task reset_tweets_gathering_progress: :environment do
  Tweet.delete_all
  DailyStat.delete_all
  HourlyStat.delete_all

  n = (ENV['DAYS'] || 7).to_i
  TencentList.all.each do |tencent_list|
    tencent_list.update_attribute :latest_tweet_timestamp, n.days.ago.to_i
  end
end
