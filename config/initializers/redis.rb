ENV['ECHIDNA_REDIS_HOST'] ||= '127.0.0.1'
ENV['ECHIDNA_REDIS_PORT'] ||= '6379'
ENV['ECHIDNA_REDIS_NAMESPACE'] = "e:#{ENV['USER']}:#{Rails.env[0]}"

$redis = Redis::Namespace.new(
  ENV['ECHIDNA_REDIS_NAMESPACE'],
  redis: Redis.new(
    host: ENV['ECHIDNA_REDIS_HOST'],
    port: ENV['ECHIDNA_REDIS_PORT'],
    driver: :hiredis
  )
)
