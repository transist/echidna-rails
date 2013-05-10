task :mock_stats => :environment do
  while true
    DailyStat.delete_all
    words = ["北京", "上海", "广州", "深圳", "天津", "重庆", "南京", "武汉", "沈阳", "西安", "成都", "杭州", "济南", "青岛", "大连", "宁波", "苏州", "无锡", "哈尔滨", "长春", "厦门", "佛山", "东莞", "合肥", "郑州", "长沙", "福州", "石家庄", "乌鲁木齐", "昆明", "兰州", "南昌", "贵阳", "南宁", "太原", "呼和浩特", "常州", "唐山", "准二线", "烟台", "泉州", "包头", "徐州", "南通", "邯郸", "温州"]
    group_id = ENV['GROUP_ID'] || Group.first.id
    (-2..0).each do |months|
      date = Date.today.ago(months.months).beginning_of_month
      words.each do |word|
        DailyStat.create word: word,
                         date: date,
                         group_id: group_id,
                         stats: (1..Time.days_in_month(date.month, date.year)).map { |day| { day: day, count: rand(100)  } }
      end
    end
    sleep 5
  end
end
