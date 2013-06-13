class TencentList
  include Mongoid::Document
  include Mongoid::Timestamps

  LIST_MAX_MEMBER_COUNT = 400

  field :list_id # The listid attribute from Tencent API
  field :name
  field :member_count, type: Integer

  belongs_to :tencent_agent

  default_scope order_by(created_at: :asc)
  scope :available, lt(member_count: LIST_MAX_MEMBER_COUNT)

  validates :list_id, presence: true, uniqueness: true
  validates :name, presence: true
end
