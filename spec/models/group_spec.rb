require 'spec_helper'
require_relative 'named_groups'

describe Group do
  it { should validate_inclusion_of(:gender).to_allow(Person::GENDERS) }
  it { should validate_inclusion_of(:gender).to_allow(nil) }
  it { should have_and_belong_to_many :panels }

  before { seed_groups }

  describe '.all_for_person' do
    include_context 'named groups'

    subject { Group.all_for_person(person) }

    context 'person with all info' do
      let(:person) { create :person, birth_year: 1990, gender: 'female', city: @city_shanghai }

      it { should have(8).groups }

      it { should include(group_1989_1995_female_shanghai) }

      it { should include(group_1989_1995_female_all) }
      it { should include(group_1989_1995_all_shanghai) }
      it { should include(group_all_female_shanghai) }

      it { should include(group_1989_1995_all_all) }
      it { should include(group_all_female_all) }
      it { should include(group_all_all_shanghai) }

      it { should include(group_all_all_all) }
    end

    context 'person with unknown gender' do
      let(:person) { create :person, birth_year: 1990, gender: 'unknown', city: @city_shanghai }

      it { should have(8).groups }

      it { should include(group_1989_1995_unknown_shanghai) }

      it { should include(group_1989_1995_unknown_all) }
      it { should include(group_1989_1995_all_shanghai) }
      it { should include(group_all_unknown_shanghai) }

      it { should include(group_1989_1995_all_all) }
      it { should include(group_all_unknown_all) }
      it { should include(group_all_all_shanghai) }

      it { should include(group_all_all_all) }
    end

    context 'person with unknown birth year' do
      let(:person) { create :person, birth_year: 0, gender: 'female', city: @city_shanghai }

      it { should have(8).groups }

      it { should include(group_0_0_female_shanghai) }

      it { should include(group_0_0_female_all) }
      it { should include(group_0_0_all_shanghai) }
      it { should include(group_all_female_shanghai) }

      it { should include(group_0_0_all_all) }
      it { should include(group_all_female_all) }
      it { should include(group_all_all_shanghai) }

      it { should include(group_all_all_all) }
    end

    context 'person with unknown city' do
      let(:person) { create :person, birth_year: 1990, gender: 'female', city: @city_unknown }

      it { should have(8).groups }

      it { should include(group_1989_1995_female_unknown) }

      it { should include(group_1989_1995_female_all) }
      it { should include(group_1989_1995_all_unknown) }
      it { should include(group_all_female_unknown) }

      it { should include(group_1989_1995_all_all) }
      it { should include(group_all_female_all) }
      it { should include(group_all_all_unknown) }

      it { should include(group_all_all_all) }
    end

    context 'person with unknown birth_year, unknown gender and unknown city' do
      let(:person) { create :person, birth_year: 0, gender: 'unknown', city: @city_unknown }

      it { should have(8).groups }

      it { should include(group_0_0_unknown_unknown) }

      it { should include(group_0_0_unknown_all) }
      it { should include(group_0_0_all_unknown) }
      it { should include(group_all_unknown_unknown) }

      it { should include(group_0_0_all_all) }
      it { should include(group_all_unknown_all) }
      it { should include(group_all_all_unknown) }

      it { should include(group_all_all_all) }
    end
  end

  describe '.all_for_panel' do
    include_context 'named groups'

    subject { Group.all_for_panel(panel) }

    context 'panel with general params' do
      let(:panel) { create :panel, age_ranges: ['1982 - 1988', '1989 - 1995'],
                    gender: 'male', city_ids: [@city_shanghai.id, @city_beijing.id]}

      it { should have(4).groups }
      it { should include(group_1982_1988_male_shanghai) }
      it { should include(group_1982_1988_male_beijing) }
      it { should include(group_1989_1995_male_shanghai) }
      it { should include(group_1989_1995_male_beijing) }
    end

    context 'panel with unknown birth_years' do
      let(:panel) { create :panel, age_ranges: ['0 - 0', '1989 - 1995'],
                    gender: 'female', city_ids: [@city_shanghai.id, @city_beijing.id]}

      it { should have(4).groups }
      it { should include(group_0_0_female_shanghai) }
      it { should include(group_0_0_female_beijing) }
      it { should include(group_1989_1995_female_shanghai) }
      it { should include(group_1989_1995_female_beijing) }
    end

    context 'panel with unknown gender' do
      let(:panel) { create :panel, age_ranges: ['1982 - 1988', '1989 - 1995'],
                    gender: 'unknown', city_ids: [@city_shanghai.id, @city_beijing.id]}

      it { should have(4).groups }
      it { should include(group_1982_1988_unknown_shanghai) }
      it { should include(group_1982_1988_unknown_beijing) }
      it { should include(group_1989_1995_unknown_shanghai) }
      it { should include(group_1989_1995_unknown_beijing) }
    end

    context 'panel with unknown city' do
      let(:panel) { create :panel, age_ranges: ['1982 - 1988', '1989 - 1995'],
                    gender: 'female', city_ids: [@city_shanghai.id, @city_unknown.id]}

      it { should have(4).groups }
      it { should include(group_1982_1988_female_shanghai) }
      it { should include(group_1982_1988_female_unknown) }
      it { should include(group_1989_1995_female_shanghai) }
      it { should include(group_1989_1995_female_unknown) }
    end

    context "panel didn't select birth_years" do
      let(:panel) { create :panel, age_ranges: [],
                    gender: 'female', city_ids: [@city_shanghai.id, @city_beijing.id]}

      it { should have(2).groups }
      it { should include(group_all_female_shanghai) }
      it { should include(group_all_female_beijing) }
    end

    context "panel didn't select gender" do
      let(:panel) { create :panel, age_ranges: ['1982 - 1988', '1989 - 1995'],
                    gender: nil, city_ids: [@city_shanghai.id, @city_beijing.id]}

      it { should have(4).groups }
      it { should include(group_1982_1988_all_shanghai) }
      it { should include(group_1982_1988_all_beijing) }
      it { should include(group_1989_1995_all_shanghai) }
      it { should include(group_1989_1995_all_beijing) }
    end

    context "panel didn't select city" do
      let(:panel) { create :panel, age_ranges: ['1982 - 1988', '1989 - 1995'],
                    gender: 'female', city_ids: []}

      it { should have(2).groups }
      it { should include(group_1982_1988_female_all) }
      it { should include(group_1989_1995_female_all) }
    end

    context "panel didn't select birth years, gender, and city" do
      let(:panel) { create :panel, age_ranges: [],
                    gender: nil, city_ids: []}

      it { should have(1).group }
      it { should include(group_all_all_all) }
    end
  end

  describe '#add_person' do
    let(:person) { create(:person_shanghai_female_1999) }
    let(:group) { create(:group) }
    before { group.add_person(person) }

    it 'add the person to group' do
      group.people.should include(person)
    end

    it 'add the group to person' do
      person.groups.should include(group)
    end

    it 'should not produce duplicate relation' do
      group.add_person(person)
      group.add_person(person)
      group.people.size.should == 1
      person.groups.size.should == 1
    end
  end
end
