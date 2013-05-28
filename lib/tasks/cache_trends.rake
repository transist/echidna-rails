namespace :cache do
  desc "cache hourly trends for all panels"
  task :hourly_trends => :environment do
    Panel.all.each { |panel| HourlyStat.top_trends(panel, panel.user, hours: 24) }
  end

  desc "cache daily trends for all panels"
  task :daily_trends => :environment do
    Panel.all.each { |panel|
      DailyStat.top_trends(panel, panel.user, days: 7)
      DailyStat.top_trends(panel, panel.user, days: 30)
    }
  end
end
