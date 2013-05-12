require 'spec_helper'

describe Group do
  it { should validate_inclusion_of(:gender).to_allow(Person::GENDERS) }
  it { should have_and_belong_to_many :people }

  let(:person) { create(:person_shanghai_female_1999) }

  describe '.all_for_person' do
    before do
      seed_groups
    end

    it 'find all groups for given person instance' do
      groups = Group.all_for_person(person)
      groups.count.should == 2
      groups.each do |group|
        [person.gender, 'both'].should include(group.gender)
        group.start_birth_year.should <= person.birth_year
        group.end_birth_year.should >= person.birth_year
        group.city.should == person.city
      end
    end
  end

  describe '#add_person' do
    let(:group) { create(:group) }
    before { group.add_person(person) }

    it 'add the person to group' do
      group.people.should include(person)
    end

    it 'add the group to person' do
      person.groups.should include(group)
    end
  end
end
