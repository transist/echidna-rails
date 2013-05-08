require 'spec_helper'

describe Tweet do
  it { should validate_presence_of :content }
  it { should validate_presence_of :url }
  it { should belong_to :person }
end
