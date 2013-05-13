# coding: utf-8
require "spec_helper"

describe Stopword do
  context ".filter" do
    it "should filter stopwords" do
      Stopword.add "我在"

      expect(Stopword.filter(["我在", "中国"])).to eq ["中国"]
    end

    it "should filter single character" do
      expect(Stopword.filter(["我", "，", "中国"])).to eq ["中国"]
    end

    it "should filter username" do
      expect(Stopword.filter(["@flyerhzm"])).to eq []
    end
  end

  it "should add stopword" do
    Stopword.add "了"
    Stopword.add "在"
    expect($redis.smembers("stopwords")).to be_include "了"
    expect($redis.smembers("stopwords")).to be_include "在"
  end

  it "should check if it is a stopword" do
    Stopword.add "了"
    expect(Stopword).to be_is "了"
  end
end
