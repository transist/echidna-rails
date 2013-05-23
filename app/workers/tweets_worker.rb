class TweetsWorker
  include SidekiqStatus::Worker
  sidekiq_options queue: :trends, retry: false

  def perform(panel_id, word, length, period)
    Sidekiq.logger.info "panel_id: #{panel_id}, word: #{word}, length: #{length}, period: #{period}"
    panel = Panel.find(panel_id)
    self.payload = {word: word, tweets: period == "days" ? DailyStat.tweets(panel, word, days: length) : HourlyStat.tweets(panel, word, hours: length)}
  end
end
