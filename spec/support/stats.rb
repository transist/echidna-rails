module Support
  module Stats
    def prepare_hourly_stats
      create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(3.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(3.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(3.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(2.days),
        stats: (0..23).map { |i| {hour: i, count: i * 2} }
      )
      create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(2.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(2.days),
        stats: (0..23).map { |i| {hour: i, count: i * 4} }
      )
      create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(1.day),
        stats: (0..23).map { |i| {hour: i, count: i * 6} }
      )
      create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(1.day),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(1.day),
        stats: (0..23).map { |i| {hour: i, count: i * 8} }
      )
      create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today,
        stats: (0..23).map { |i| {hour: i, count: i * 10} }
      )
      create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today,
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today,
        stats: (0..23).map { |i| {hour: i, count: i * 12} }
      )
    end

    def prepare_daily_stats
      date = Date.today.ago(3.months).beginning_of_month
      create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
      )
      create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
      )
      create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
      )

      date = Date.today.ago(2.months).beginning_of_month
      create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 2} }
      )
      create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
      )
      create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 4} }
      )

      date = Date.today.ago(1.month).beginning_of_month
      create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 6} }
      )
      create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
      )
      create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 8} }
      )

      date = Date.today.beginning_of_month
      create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 10} }
      )
      create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i} }
      )
      create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: date,
        stats: (1..Time.days_in_month(date.month, date.year)).map { |i| {day: i, count: i * 12} }
      )
    end
  end
end

RSpec.configure do |config|
  config.include Support::Stats
end
