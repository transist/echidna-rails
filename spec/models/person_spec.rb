require 'spec_helper'

describe Person do
  it { should validate_inclusions_of(:gender).to_allow(%w(Men Women Both)) }
  it { should have_many :tweets }
  it { should belong_to :city }
  it { should belong_to :group }
end
