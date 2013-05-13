# coding: utf-8
require "spec_helper"

describe Segment do
  context "segments" do
    context "without optimize" do
      it "should get segments" do
        expect(Segment.get("我喜欢玩，我喜欢睡觉").map { |segement| segement.force_encoding("UTF-8")}).to eq  ["我", "喜欢", "玩", "，", "我", "喜欢", "睡觉"]
      end

      it "should get segments with stopword" do
        Stopword.add "，"
        Stopword.add "我"
        expect(Segment.get("我喜欢玩，我喜欢睡觉").map { |segement| segement.force_encoding("UTF-8")}).to eq  ["我", "喜欢", "玩", "，", "我", "喜欢", "睡觉"]
      end
    end

    context "with optimize" do
      it "should get segments" do
        expect(Segment.get("我喜欢玩，我喜欢睡觉", optimize: true).map { |segement| segement.force_encoding("UTF-8")}).to eq ["喜欢", "我", "玩", "睡觉", "，"]
      end

      it "should get segments with stopwords" do
        Stopword.add "，"
        Stopword.add "我"
        expect(Segment.get("我喜欢玩，我喜欢睡觉", optimize: true).map { |segement| segement.force_encoding("UTF-8")}).to eq ["喜欢", "玩", "睡觉"]
      end
    end
  end
end
