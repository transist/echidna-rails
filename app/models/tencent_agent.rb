class TencentAgent
  include Mongoid::Document
  include UsersSampling
  include UsersTracking
  include TweetsGathering
  include ApiResponseCacher

  field :openid, type: String
  field :name, type: String
  field :nick, type: String
  field :access_token, type: String
  field :refresh_token, type: String
  field :expires_at, type: Integer

  field :list_ids, type: Array, default: []
  field :list_last_timestamp_map, type: Hash, default: {}
  field :full_with_lists, type: Boolean, default: false

  field :api_calls_count, type: Integer, default: 0

  def get(path, params = {}, &block)
    access_token.get(path, params: params, &block).parsed
  end

  def post(path, body = {}, &block)
    access_token.post(path, body: body, &block).parsed
  end

  def refresh_access_token
    if Time.at(expires_at.to_i) - Time.now <= 1.day
      refresh_access_token!
    end
  rescue => e
    log_unexpected_error(e)
  end

  def refresh_access_token!
    info 'Refreshing access token...'
    new_token = access_token.refresh!
    update_attributes(new_token.to_hash.symbolize_keys)
    info 'Finished access token refreshing'
  end

  def self.weibo_client
    Tencent::Weibo::Client.new(
      ENV['ECHIDNA_SPIDER_TENCENT_APP_KEY'],
      ENV['ECHIDNA_SPIDER_TENCENT_APP_SECRET'],
      ENV['ECHIDNA_SPIDER_TENCENT_REDIRECT_URI']
    )
  end

  def info(message)
    self.class.logger.info(log_wrapper(message))
  end

  def warn(message)
    self.class.logger.warn(log_wrapper(message))
  end

  def error(message)
    self.class.logger.error(log_wrapper(message))
  end

  private

  def self.logger
    @logger ||= Logger.new('log/spider.log', 10, 1024000)
  end

  def log_wrapper(message)
    "#{Time.now.to_s} Tencent Weibo agent #{name}: #{message}"
  end

  def access_token
    @weibo ||= self.class.weibo_client
    @access_token ||= Tencent::Weibo::AccessToken.from_hash(@weibo, attributes)
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

    error(error)
    info(exception.inspect)
  end

end
