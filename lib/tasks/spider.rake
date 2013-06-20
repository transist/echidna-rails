desc "Spider Scheduler"
task :spider_scheduler => :environment do
  # temporarily check pid to promise only one spider_scheduler is
  # running
  # I prefer using monit to check in the future
  pid_file = 'tmp/pids/spider_scheduler.pid'
  system("kill -TERM `cat #{pid_file}` 2> /dev/null") if File.exists? pid_file
  File.open(pid_file, 'w') { |f| f.puts Process.pid }

  scheduler = SpiderScheduler.new
  scheduler.run
  scheduler.join
end
