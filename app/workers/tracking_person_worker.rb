class TrackingPersonWorker
  include Sidekiq::Worker

  def perform(person_id)
    person = Person.find person_id

    agent = TencentAgent.get_agent_with_capacity
    agent.track_users([person.targe_id])
  end

end
