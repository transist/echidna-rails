set :output, "/home/echidna/echidna.transi.st/current/log/whenever.log"
job_type :rake, "source /home/echidna/.bashrc && cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"

every '5 * * * *' do
  rake "cache:hourly_trends"
end

every 1.day, :at => '0:05 am' do
  rake "cache:daily_trends"
end
