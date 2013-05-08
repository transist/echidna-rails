require 'spec_helper'

describe Group do
  it { should validate_inclusion_of(:gender).to_allow(%w(Male Female Both)) }
  it { should have_many :persons }
end
