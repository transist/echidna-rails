module Support
  module Stats
    def prepare_hourly_stats(panel)
      panel.groups.each do |group|
        create(:hourly_stat,
          word: "中国",
          group_id: group.id,
          date: 3.days.ago,
          stats: (0..23).map { |i| {hour: i, count: i} }
        )
        create(:hourly_stat,
          word: "美国",
          group_id: group.id,
          date: 3.days.ago,
          stats: (0..23).map { |i| {hour: i, count: i} }
        )
        create(:hourly_stat,
          word: "日本",
          group_id: group.id,
          date: 3.days.ago,
          stats: (0..23).map { |i| {hour: i, count: i} }
        )
        create(:hourly_stat,
          word: "中国",
          group_id: group.id,
          date: 2.days.ago,
          stats: (0..23).map { |i| {hour: i, count: i * 2} }
        )
        create(:hourly_stat,
          word: "美国",
          group_id: group.id,
          date: 2.days.ago,
          stats: (0..23).map { |i| {hour: i, count: i} }
        )
        create(:hourly_stat,
          word: "日本",
          group_id: group.id,
          date: 2.days.ago,
          stats: (0..23).map { |i| {hour: i, count: i * 4} }
        )
        create(:hourly_stat,
          word: "中国",
          group_id: group.id,
          date: 1.day.ago,
          stats: (0..23).map { |i| {hour: i, count: i * 6} }
        )
        create(:hourly_stat,
          word: "美国",
          group_id: group.id,
          date: 1.day.ago,
          stats: (0..23).map { |i| {hour: i, count: i} }
        )
        create(:hourly_stat,
          word: "日本",
          group_id: group.id,
          date: 1.day.ago,
          stats: (0..23).map { |i| {hour: i, count: i * 8} }
        )
        create(:hourly_stat,
          word: "中国",
          group_id: group.id,
          date: Date.today,
          stats: (0..23).map { |i| {hour: i, count: i * 10} }
        )
        create(:hourly_stat,
          word: "美国",
          group_id: group.id,
          date: Date.today,
          stats: (0..23).map { |i| {hour: i, count: i} }
        )
        create(:hourly_stat,
          word: "日本",
          group_id: group.id,
          date: Date.today,
          stats: (0..23).map { |i| {hour: i, count: i * 12} }
        )
      end
    end

    def prepare_daily_stats(panel)
      panel.groups.each do |group|
        date = 3.months.ago.beginning_of_month
        create(:daily_stat,
          word: "中国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
        )
        create(:daily_stat,
          word: "美国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
        )
        create(:daily_stat,
          word: "日本",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
        )

        date = 2.months.ago.beginning_of_month
        create(:daily_stat,
          word: "中国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 2} }
        )
        create(:daily_stat,
          word: "美国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
        )
        create(:daily_stat,
          word: "日本",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 4} }
        )

        date = 1.month.ago.beginning_of_month
        create(:daily_stat,
          word: "中国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 6} }
        )
        create(:daily_stat,
          word: "美国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
        )
        create(:daily_stat,
          word: "日本",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 8} }
        )

        date = Date.today.beginning_of_month
        create(:daily_stat,
          word: "中国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 10} }
        )
        create(:daily_stat,
          word: "美国",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
        )
        create(:daily_stat,
          word: "日本",
          group_id: group.id,
          date: date,
          stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 12} }
        )
      end
    end
  end
end

RSpec.configure do |config|
  config.include Support::Stats
end
