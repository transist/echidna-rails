require 'spec_helper'

describe Panel do
  it { should belong_to :user }
  it { should have_and_belong_to_many :cities }
  it { should have_and_belong_to_many :groups }

  let(:panel) { create :panel, age_ranges: ["1982 - 1988", "1989 - 1995"]}

  describe "#start_years" do
    subject { panel }
    its(:start_years) { should eq %w(1982 1989) }
  end

  describe "#end_years" do
    subject { panel }
    its(:end_years) { should eq %w(1988 1995) }
  end
end
