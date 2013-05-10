module Support
  module Stats
    def prepare_hourly_stats
      FactoryGirl.create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(3.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(3.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(3.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(2.days),
        stats: (0..23).map { |i| {hour: i, count: i * 2} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(2.days),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(2.days),
        stats: (0..23).map { |i| {hour: i, count: i * 4} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(1.day),
        stats: (0..23).map { |i| {hour: i, count: i * 6} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(1.day),
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(1.day),
        stats: (0..23).map { |i| {hour: i, count: i * 8} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word1",
        group_id: 1,
        date: Date.today,
        stats: (0..23).map { |i| {hour: i, count: i * 10} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word2",
        group_id: 1,
        date: Date.today,
        stats: (0..23).map { |i| {hour: i, count: i} }
      )
      FactoryGirl.create(:hourly_stat,
        word: "word3",
        group_id: 1,
        date: Date.today,
        stats: (0..23).map { |i| {hour: i, count: i * 12} }
      )
    end

    def prepare_daily_stats
      FactoryGirl.create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(3.months).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(3.months).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(3.months).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(2.months).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i * 2} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(2.months).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(2.months).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i * 4} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.ago(1.month).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i * 6} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.ago(1.month).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.ago(1.month).beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i * 8} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word1",
        group_id: 1,
        date: Date.today.beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i * 10} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word2",
        group_id: 1,
        date: Date.today.beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i} }
      )
      FactoryGirl.create(:daily_stat,
        word: "word3",
        group_id: 1,
        date: Date.today.beginning_of_month,
        stats: (1..31).map { |i| {day: i, count: i * 12} }
      )
    end
  end
end

RSpec.configure do |config|
  config.include Support::Stats
end
