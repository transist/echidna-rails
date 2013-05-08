require 'spec_helper'

describe Person do
  it { should validate_inclusion_of(:gender).to_allow(%w(Male Female Both)) }
  it { should have_many :tweets }
  it { should belong_to :city }
  it { should belong_to :group }
end
