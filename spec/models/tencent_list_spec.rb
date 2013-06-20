require 'spec_helper'

describe TencentList do
  it { should validate_presence_of :list_id }
  it { should validate_uniqueness_of :list_id }
  it { should validate_presence_of :name }
end
