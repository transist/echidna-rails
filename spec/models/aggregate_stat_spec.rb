require 'spec_helper'

describe AggregateStat do
  describe ".words_scores" do
    it "returns words with z_scores" do
      expect(AggregateStat.words_scores(
        [{
          "中国" => [30, 40, 50, 60, 70, 80, 90],
          "美国" => [3, 4, 5, 6, 7, 8, 9],
          "日本" => [36, 48, 60, 72, 84, 96, 108]
        }],
        [{
          "中国" => 100, "美国" => 10, "日本" => 120
        }]
      )).to eq([
        {word: "美国", z_score: 1.4804519606800843},
        {word: "中国", z_score: 1.4804519606800841},
        {word: "日本", z_score: 1.4804519606800841}
      ])
    end

    it "returns 0s if we don't have enough history stats" do
      expect(AggregateStat.words_scores(
        [{
          "中国" => [90], "美国" => [9], "日本" => [108]
        }],
        [{
          "中国" => 100, "美国" => 10, "日本" => 120
        }]
      )).to eq([
        {word: "中国", z_score: 0},
        {word: "美国", z_score: 0},
        {word: "日本", z_score: 0}
      ])
    end

    it "aggregates multiple stats" do
      expect(AggregateStat.words_scores(
        [{
          "中国" => [30, 40, 50, 60, 70, 80, 90],
          "美国" => [3, 4, 5, 6, 7, 8, 9],
          "日本" => [36, 48, 60, 72, 84, 96, 108]
        },
        {
          "中国" => [30, 40, 50, 60, 70, 80, 90],
          "美国" => [3, 4, 5, 6, 7, 8, 9],
          "日本" => [36, 48, 60, 72, 84, 96, 108]
        }],
        [{
          "中国" => 100, "美国" => 10, "日本" => 120
        }, {
          "中国" => 100, "美国" => 10, "日本" => 120
        }]
      )).to eq([
        {word: "美国", z_score: 1.4804519606800843},
        {word: "中国", z_score: 1.4804519606800841},
        {word: "日本", z_score: 1.4804519606800841}
      ])
    end
  end
end
