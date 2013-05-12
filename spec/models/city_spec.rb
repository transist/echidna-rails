require 'spec_helper'

describe City do
  it { should have_and_belong_to_many :panels }
  it { should have_many :groups }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
end
