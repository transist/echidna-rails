desc "Spider Scheduler"
task :spider_scheduler => :environment do
  scheduler = SpiderScheduler.new
  scheduler.run
  scheduler.join
end