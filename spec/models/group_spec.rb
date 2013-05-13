require 'spec_helper'

describe Group do
  it { should validate_inclusion_of(:gender).to_allow(Person::GENDERS) }
  it { should have_and_belong_to_many :people }
  it { should have_and_belong_to_many :panels }

  let(:person) { create(:person_shanghai_female_1999) }

  before { seed_groups }

  describe '.all_for_person' do
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

  describe ".all_for_panel" do
    let(:shanghai_city) { City.where(name: '上海').first }
    let(:beijing_city) { City.where(name: '北京').first }
    let(:panel) { create :panel, age_ranges: ["1982 - 1988", "1989 - 1995"],
                                 gender: 'male',
                                 city_ids: [shanghai_city.id, beijing_city.id]}
    subject { Group.all_for_panel(panel) }

    it { should have(8).groups }
    it { should be_include(Group.where(start_birth_year: "1982", end_birth_year: "1988", gender: "male", city_id: shanghai_city.id).first) }
    it { should be_include(Group.where(start_birth_year: "1982", end_birth_year: "1988", gender: "male", city_id: beijing_city.id).first) }
    it { should be_include(Group.where(start_birth_year: "1982", end_birth_year: "1988", gender: "both", city_id: shanghai_city.id).first) }
    it { should be_include(Group.where(start_birth_year: "1982", end_birth_year: "1988", gender: "both", city_id: beijing_city.id).first) }
    it { should be_include(Group.where(start_birth_year: "1989", end_birth_year: "1995", gender: "male", city_id: shanghai_city.id).first) }
    it { should be_include(Group.where(start_birth_year: "1989", end_birth_year: "1995", gender: "male", city_id: beijing_city.id).first) }
    it { should be_include(Group.where(start_birth_year: "1989", end_birth_year: "1995", gender: "both", city_id: shanghai_city.id).first) }
    it { should be_include(Group.where(start_birth_year: "1989", end_birth_year: "1995", gender: "both", city_id: beijing_city.id).first) }
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
