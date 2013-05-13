# coding: utf-8
require "spec_helper"

describe Hypernym do
  before do
    Hypernym.set("凯恩斯主义", "宏观经济学")
    Hypernym.set("凯恩斯主义", "经济自由主义")
  end

  it "should get hypernyms" do
    hypernyms = Hypernym.get("凯恩斯主义")
    expect(hypernyms).to be_include "宏观经济学"
    expect(hypernyms).to be_include "经济自由主义"
  end
end
