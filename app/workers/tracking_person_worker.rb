class TrackingPersonWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :spider

  def perform(person_id)
    person = Person.find person_id

    agent = TencentAgent.get_agent_with_capacity
    agent.track_users([person.target_id])
  end

end
