require 'spec_helper'

describe HourlyStat do
  context ".top_trends" do
    before do
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
    before do
      Timecop.freeze(Time.now.change(hour: 10))
    end

    after do
      Timecop.return
    end

    it "returns word1, word3 and word2 for group 1" do
      expect(HourlyStat.top_trends(1)).to eq %w(word1 word3 word2)
    end

    it "returns nothing for group 2" do
      expect(HourlyStat.top_trends(2)).to eq []
    end

    it "checks history for only 1 hour" do
      expect(HourlyStat.top_trends(1, hours: 1)).to eq %w(word1 word2 word3)
    end
  end
end
