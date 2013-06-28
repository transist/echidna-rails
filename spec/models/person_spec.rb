require 'spec_helper'

describe Person do
  it { should validate_inclusion_of(:gender).to_allow(Person::GENDERS) }
  it { should have_many :tweets }
  it { should belong_to :city }
  it { should have_and_belong_to_many :groups }

  describe '#add_to_group' do
    let(:person) { create(:person_shanghai_female_1999) }
    let(:groups) { create_list(:group, 3) }
    before { person.add_to_groups(groups) }

    it 'add person to groups' do
      groups.each do |group|
        group.people.should include(person)
      end
    end

    it 'add groups to person' do
      groups.each do |group|
        person.groups.should include(group)
      end
    end

    it 'should not produce duplicate relation' do
      person.add_to_groups(groups)
      person.add_to_groups(groups)
      groups.each do |group|
        group.people.should have(1).people
      end
      person.groups.should have(3).groups
    end
  end
end
