class TencentAgent
  include Mongoid::Document

  def get(path, params = {}, &block)
    access_token.get(path, params: params, &block).parsed
  end

  def post(path, body = {}, &block)
    access_token.post(path, body: body, &block).parsed
  end

  def refresh_access_token
    if Time.at(expires_at.to_i) - Time.now <= 1.day
      puts log('Refreshing access token...')
      new_token = access_token.refresh!
      TencentAgent.create(new_token.to_hash.symbolize_keys)
      puts log('Finished access token refreshing')
    end
  rescue => e
    log_unexpected_error(e)
  end

  private
  def weibo
    @weibo ||= begin
      config = YAML::load(File.open(Rails.root.join("config/spider.yml")))
      
      Tencent::Weibo::Client.new(
        config['tencent']['key'], config['tencent']['secret'], config['tencent']['redirect_uri']
      )
    end
  end

  def access_token
    @access_token ||= Tencent::Weibo::AccessToken.from_hash(weibo, attributes)
  end

  def log(message)
    "Tencent Weibo agent #{name}: #{message}"
  end

  # Log unexpected errors to a redis list
  def log_unexpected_error(exception)
    error = {
      class: exception.class.name,
      message: exception.message,
      backtrace: exception.backtrace,
      raised_at: Time.now
    }
    if exception.respond_to?(:response)
      faraday_response = exception.response.response.to_hash
      # Delete self-reference
      faraday_response.delete(:response)
      faraday_response[:url] = faraday_response[:url].to_s
      faraday_response[:body] = MultiJson.load(faraday_response[:body]) rescue faraday_response[:body]

      error[:response] = faraday_response
    end

    puts log(error)
    puts log(exception.inspect)
  end

end