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

  field :available_for_tracking_users, type: Boolean, default: true

  has_many :tencent_lists

  scope :available_for_tracking_users, where(available_for_tracking_users: true)

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

  def sync_lists
    result = get('api/list/get_list')

    if result['ret'].to_i.zero?
      result['data']['info'].map do |list|
        tencent_list = tencent_lists.find_or_initialize_by(list_id: list['listid'])
        tencent_list.update_attributes!(
          name: list['name'],
          member_count: list['membernums'],
          created_at: Time.at(list['createtime'].to_i)
        )
      end

    else
      raise Error, "Failed to sync lists: #{result['msg']}"
    end
  end

  def mark_as_unavailable_for_tracking_users
    update_attribute :available_for_tracking_users, false
  end

  private

  def access_token
    @weibo ||= self.class.weibo_client
    @access_token ||= Tencent::Weibo::AccessToken.from_hash(@weibo, attributes)
  end
end
