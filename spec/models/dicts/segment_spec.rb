# coding: utf-8
require "spec_helper"

describe Segment do
  context "segments" do
    it "should get segments" do
      expect(Segment.get("我喜欢玩，我喜欢睡觉")).to eq ["我", "喜欢", "玩", "我", "喜欢", "睡觉"]
    end

    it "should get segments with stopword" do
      Stopword.add "玩"
      Stopword.add "我"
      expect(Segment.get("我喜欢玩，我喜欢睡觉")).to eq ["喜欢", "喜欢", "睡觉"]
    end
  end
end
