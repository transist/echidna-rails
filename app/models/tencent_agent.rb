class TencentAgent
  include Mongoid::Document
  include UsersSampling
  include ApiResponseCacher

  field :openid, type: String
  field :name, type: String
  field :nick, type: String
  field :access_token, type: String
  field :refresh_token, type: String
  field :expires_at, type: Integer

  def get(path, params = {}, &block)
    access_token.get(path, params: params, &block).parsed
  end

  def post(path, body = {}, &block)
    access_token.post(path, body: body, &block).parsed
  end

  def refresh_access_token
    if Time.at(expires_at.to_i) - Time.now <= 1.day
      $spider_logger.info log('Refreshing access token...')
      new_token = access_token.refresh!
      TencentAgent.create(new_token.to_hash.symbolize_keys)
      $spider_logger.info log('Finished access token refreshing')
    end
  rescue => e
    log_unexpected_error(e)
  end

  def self.weibo_client
    Tencent::Weibo::Client.new(
      ENV['ECHIDNA_SPIDER_TENCENT_APP_KEY'],
      ENV['ECHIDNA_SPIDER_TENCENT_APP_SECRET'],
      ENV['ECHIDNA_SPIDER_TENCENT_REDIRECT_URI']
    )
  end

  private

  def access_token
    @weibo ||= self.class.weibo_client
    @access_token ||= Tencent::Weibo::AccessToken.from_hash(@weibo, attributes)
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

    $spider_logger.error log(error)
    $spider_logger.info log(exception.inspect)
  end

end
