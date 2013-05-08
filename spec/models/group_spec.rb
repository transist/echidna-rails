require 'spec_helper'

describe Group do
  it { should validate_inclusions_of(:gender).to_allow(%w(Male Female Both)) }
  it { should have_many :persons }
  it { should have_many :cities }
end
