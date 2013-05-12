require 'spec_helper'

describe Person do
  it { should validate_inclusion_of(:gender).to_allow(Person::GENDERS) }
  it { should have_many :tweets }
  it { should belong_to :city }
  it { should have_and_belong_to_many :groups }
end
