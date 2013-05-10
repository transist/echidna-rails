require 'spec_helper'

describe Group do
  it { should validate_inclusion_of(:gender).to_allow(Person::GENDERS) }
  it { should have_and_belong_to_many :people }
end
