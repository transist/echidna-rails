desc 'Purge the tweets and stats, then reset tweets gathering progress to given days ago.'
task reset_tweets_gathering_progress: :environment do
  Tweet.delete_all
  DailyStat.delete_all
  HourlyStat.delete_all

  n = (ENV['DAYS'] || 7).to_i
  TencentAgent.all.each do |agent|
    agent.list_last_timestamp_map =
      Hash[agent.list_last_timestamp_map.map {|list_id, timestamp| [list_id, n.days.ago.to_i] }]
    agent.save
  end
end
