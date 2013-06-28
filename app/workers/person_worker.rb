class PersonWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :spider

  def perform(person_attrs)
    unless Person.where(
      target_source: person_attrs['target_source'],
      target_id: person_attrs['target_id']
    ).exists?

      city = City.where(name: person_attrs.delete('city')).first
      person = Person.create!(person_attrs.merge(city: city))

      person.add_to_groups Group.all_for_person(person)
    end
  end
end
