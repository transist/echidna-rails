# coding: utf-8
require "spec_helper"

describe Synonym do
  before do
    Synonym.set("本来", "原本")
    Synonym.set("原先", "本来")
    Synonym.set("本来", "原来")
  end

  it "should get synonyms" do
    synonyms = Synonym.get("本来")
    expect(synonyms).to be_include "原本"
    expect(synonyms).to be_include "原先"
    expect(synonyms).to be_include "原来"
  end
end
