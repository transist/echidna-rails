require 'spec_helper'

describe PersonWorker do
  before do
    seed_groups
    create :tencent_agent
  end

  let(:person_attrs) { {
    target_source: 'tencent',
    target_id: '5a67a4b2818d0651ad5b70091ad6c73a',
    target_name: 'Lolita',
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

    context 'the person already exists' do
      before do
        PersonWorker.perform_async(person_attrs)
      end

      it 'should not save duplicate person' do
        expect {
          PersonWorker.perform_async(person_attrs)
        }.to_not change(Person, :count)
      end

      it 'should not raise error' do
        expect {
          PersonWorker.perform_async(person_attrs)
        }.to_not raise_error
      end
    end
  end
end
