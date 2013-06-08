require 'tencent_agent/error'

class TencentAgent
  include Mongoid::Document
  include Mongoid::Timestamps

  include TencentLogger
  include FamousUsersSampling
  include HotUsersSampling
  include UsersSampling
  include UsersSamplingFromFollowingOfFamous
  include UsersTracking
  include TweetsGathering
  include ApiCallsLimiter
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

  scope :with_available_lists, where(full_with_lists: false)

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

  private

  def access_token
    @weibo ||= self.class.weibo_client
    @access_token ||= Tencent::Weibo::AccessToken.from_hash(@weibo, attributes)
  end
end
