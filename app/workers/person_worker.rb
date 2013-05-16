class PersonWorker
  include Sidekiq::Worker

  def perform(person_attrs)
    target = {target_source: 'tencent', target_id: person_attrs['openid']}

    unless Person.where(target_id: target[:target_id]).where(target_source: target[:target_source]).count > 0
      city = City.where(name: person_attrs.delete('city')).first

      person = Person.create(person_attrs.merge(city: city).merge(target))

      Group.all_for_person(person).each do |group|
        group.add_person(person)
      end

      #Batch added to list supported
      TrackingPersonWorker.perform_async(person.id)
    end
  end
end
