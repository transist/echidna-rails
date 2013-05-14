$redis = Redis::Namespace.new(
  "e:#{Rails.env[0]}",
  redis: Redis.new(
    host: ENV['ECHIDNA_REDIS_HOST'],
    port: ENV['ECHIDNA_REDIS_PORT'],
    driver: :hiredis
  )
)
