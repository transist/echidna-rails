# coding: utf-8
require "spec_helper"

describe Homonym do
  context "#add_pinyin" do
    before do
      Homonym.add_pinyin("我", "wǒ")
    end

    it "should add char_to_pinyin key" do
      expect($redis.smembers("c2py/我")).to be_include "wǒ"
    end

    it "should add pinyin_to_char key" do
      expect($redis.smembers("py2c/wǒ")).to be_include "我"
    end
  end

  context "#get" do
    before do
      Word.add("富裕")
      Word.add("馥郁")
      Word.add("负隅")
      Homonym.add_pinyin("富", "fù")
      Homonym.add_pinyin("裕", "yù")
      Homonym.add_pinyin("馥", "fù")
      Homonym.add_pinyin("郁", "yù")
      Homonym.add_pinyin("付", "fù")
      Homonym.add_pinyin("狱", "yù")
      Homonym.add_pinyin("负", "fù")
      Homonym.add_pinyin("隅", "yù")
      Homonym.prepare_pinyin_for_words
    end

    it "should be homonyms (富裕 and 馥郁)" do
      expect(Homonym.get("富裕")).to be_include "馥郁"
      expect(Homonym.get("馥郁")).to be_include "富裕"
    end

    it "should be homonyms (富裕 and 负隅)" do
      expect(Homonym.get("富裕")).to be_include "负隅"
      expect(Homonym.get("负隅")).to be_include "富裕"
    end

    it "should not be homonyms (富裕 and 付狱)" do
      expect(Homonym.get("富裕")).not_to be_include "付狱"
    end
  end
end
