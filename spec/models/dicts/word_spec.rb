# coding: utf-8
require "spec_helper"

describe Word do
  before do
    Word.add("原本")
  end

  it "should exist (原本)" do
    expect(Word).to be_exist "原本"
  end

  it "should not exist (原先)" do
    expect(Word).not_to be_exist "原先"
  end
end
