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

      Group.all_for_person(person).each do |group|
        group.add_person(person)
      end

      #Batch added to list supported
      # TrackingPersonWorker.perform_async(person._id.to_s)
    end
  end
end
