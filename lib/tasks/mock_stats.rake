task :mock_stats => :environment do
  DailyStat.delete_all
  HourlyStat.delete_all
  words = ["北京", "上海", "广州", "深圳", "天津", "重庆", "南京", "武汉", "沈阳", "西安", "成都", "杭州", "济南", "青岛", "大连", "宁波", "苏州", "无锡", "哈尔滨", "长春", "厦门", "佛山", "东莞", "合肥", "郑州", "长沙", "福州", "石家庄", "乌鲁木齐", "昆明", "兰州", "南昌", "贵阳", "南宁", "太原", "呼和浩特", "常州", "唐山", "准二线", "烟台", "泉州", "包头", "徐州", "南通", "邯郸", "温州"]
  panel_id = ENV["PANEL_ID"] || Panel.last.id
  Panel.find(panel_id).groups.each do |group|
    words.each do |word|
      (0..7).each do |i|
        date = i.months.ago.beginning_of_month
        DailyStat.create word: word,
                         date: date,
                         group_id: group.id,
                         stats: (1..Time.days_in_month(date.month, date.year)).map { |day| { day: day, count: rand(100)  } }

        date = i.days.ago.beginning_of_day
        HourlyStat.create word: word,
                          date: date,
                          group_id: group.id,
                          stats: (0..23).map { |hour| { hour: hour, count: rand(100)  } }
      end
    end
  end
end
