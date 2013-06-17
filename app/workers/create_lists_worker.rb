class CreateListsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :spider

  def perform(tencent_agent_id)
    TencentAgent.find(tencent_agent_id).create_lists
  end
end
