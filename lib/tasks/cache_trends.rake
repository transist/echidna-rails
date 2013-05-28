namespace :cache do
  desc "cache hourly trends for all panels"
  task :hourly_trends => :environment do
    Panel.all.each { |panel| HourlyStat.top_trends(panel, panel.user) }
  end

  desc "cache daily trends for all panels"
  task :daily_trends => :environemnt do
    Panel.all.each { |panel|
      DailyStat.top_trends(panel, panel.user)
      DailyStat.top_trends(panel, panel.user, days: 30)
    }
  end
end
