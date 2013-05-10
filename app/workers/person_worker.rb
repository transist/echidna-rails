class PersonWorker
  include Sidekiq::Worker

  def perform(person_attrs)
    city = City.where(name: person_attrs.delete('city')).first
    person = Person.new(person_attrs.merge(city: city))

    Group.all_for_person(person).each do |group|
      group.add_person(person)
    end
  end
end
