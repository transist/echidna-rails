set :output, "/home/echidna/echidna.transi.st/current/log/whenever.log"

every '5 * * * *' do
  rake "cache:hourly_trends"
end

every 1.day, :at => '0:05 am' do
  rake "cache:daily_trends"
end
