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

  LIST_NAME_PREFIX = 'UTL'

  field :openid, type: String
  field :name, type: String
  field :nick, type: String
  field :access_token, type: String
  field :refresh_token, type: String
  field :expires_at, type: Integer

  field :available_for_tracking_users, type: Boolean, default: true

  has_many :tencent_lists

  scope :available_for_tracking_users, where(available_for_tracking_users: true)

  after_create :create_lists_async

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
      synced_lists = result['data']['info'].map do |list|
        tencent_list = tencent_lists.find_or_initialize_by(list_id: list['listid'])
        tencent_list.update_attributes!(
          name: list['name'],
          member_count: list['membernums'],
          created_at: Time.at(list['createtime'].to_i)
        )
        tencent_list
      end

      (tencent_lists - synced_lists).map(&:delete)
      reload.tencent_lists

    elsif result['ret'].to_i == 1 && result['errcode'].to_i == 44
      # Tencent API treat the case agent don't have any list yet as
      # error, and return this error code combination.
      tencent_lists.delete_all
      reload.tencent_lists

    else
      raise TencentError, "Failed to sync lists: #{result['msg']}"
    end
  end

  def create_lists
    count = 0
    loop do
      # Humanized 1 based name sequence
      # The maximized allowd name length is 13
      list_name = '%s_%09d' % [LIST_NAME_PREFIX, count + 1]

      break unless create_list(list_name)
      count += 1
    end
  ensure
    sync_lists
    info "Created #{count} lists"
  end

  def mark_as_unavailable_for_tracking_users
    update_attribute :available_for_tracking_users, false
  end

  private

  def create_lists_async
    CreateListsWorker.perform_async(id.to_s)
  end

  def access_token
    @weibo ||= self.class.weibo_client
    @access_token ||= Tencent::Weibo::AccessToken.from_hash(@weibo, attributes)
  end

  def create_list(list_name)
    result = post('api/list/create', name: list_name, access: 1)
    if result['ret'].to_i.zero?
      info %{Created list "#{list_name}"}
      true

    elsif result['ret'].to_i == 4 and result['errcode'].to_i == 98
      # List limitation of maximized members reached
      false

    else
      raise TencentError.new(%{Failed to create list "#{list_name}"}, result)
    end
  end
end
