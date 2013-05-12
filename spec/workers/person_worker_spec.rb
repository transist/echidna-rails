require 'spec_helper'

describe PersonWorker do
  before do
    seed_groups
  end

  let(:person_attrs) { {
    target_id: 1234567890,
    target_source: 'tencent',
    birth_year: 1999,
    gender: 'female',
    city: '上海'
  } }

  describe '#perform' do
    it 'save the person' do
      expect {
        PersonWorker.perform_async(person_attrs)
      }.to change(Person, :count).by(1)
    end

    it 'add the person to corresponding groups' do
      PersonWorker.perform_async(person_attrs)

      person = Person.first
      groups = Group.all_for_person(person)

      groups.count.should > 0

      groups.each do |group|
        person.groups.should include(group)
        group.people.should include(person)
      end
    end
  end
end
