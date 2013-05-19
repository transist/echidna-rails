Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
    chain.remove Sidekiq::Middleware::Server::ActiveRecord
  end

  config.redis = { namespace: "e:sidekiq:#{Rails.env[0]}" }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: "e:sidekiq:#{Rails.env[0]}" }
end
