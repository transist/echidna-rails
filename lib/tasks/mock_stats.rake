task :mock_stats => :environment do
  DailyStat.delete_all
  HourlyStat.delete_all
  words = ["北京", "上海", "广州", "深圳", "天津", "重庆", "南京", "武汉", "沈阳", "西安", "成都", "杭州", "济南", "青岛", "大连", "宁波", "苏州", "无锡", "哈尔滨", "长春", "厦门", "佛山", "东莞", "合肥", "郑州", "长沙", "福州", "石家庄", "乌鲁木齐", "昆明", "兰州", "南昌", "贵阳", "南宁", "太原", "呼和浩特", "常州", "唐山", "准二线", "烟台", "泉州", "包头", "徐州", "南通", "邯郸", "温州"]
  panel_id = ENV["PANEL_ID"] || Panel.last.id
  while true
    panel = Panel.find(panel_id)
    DailyStat.where(:group_id.in => panel.group_ids).destroy_all
    HourlyStat.where(:group_id.in => panel.group_ids).destroy_all
    Tweet.destroy_all

    Tweet.skip_callback(:create, :after, :update_stats)
    100.times do |i|
      Tweet.create target_id: rand(10000), content: words.sample(5).join(' '), posted_at: rand(24).hours.ago
    end
    tweet_ids = Tweet.all.map(&:id)

    panel.group_ids.each do |group_id|
      (0..1).each do |i|
        daily_date = i.months.ago.beginning_of_month
        month_distance = Time.days_in_month(daily_date.month, daily_date.year)
        hourly_date = i.days.ago.beginning_of_day
        words.each do |word|
          DailyStat.create word: word,
                           date: daily_date,
                           group_id: group_id,
                           stats: (1..month_distance).map { |day| { day: day, count: rand(100), tweet_ids: tweet_ids.sample(10) } }

          HourlyStat.create word: word,
                            date: hourly_date,
                            group_id: group_id,
                            stats: (0..23).map { |hour| { hour: hour, count: rand(100), tweet_ids: tweet_ids.sample(10)  } }
        end
      end
    end
    puts "finshed one loop!!!"
    sleep 1
  end
end
