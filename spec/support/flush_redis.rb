RSpec.configure do |config|
  def flush_redis
    $redis.keys('*').each do |key|
      $redis.del key
    end
  end

  config.after do
    flush_redis
  end
end
