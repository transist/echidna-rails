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

  before_destroy :delete_tencent_list

  def track(people)
    people_to_track = people[0, capacity]
    remaining_people = people[people_to_track.size..-1]
    user_openids = people_to_track.map(&:target_id)

    result = tencent_agent.post('api/list/add_to_list', fopenids: user_openids.join('_'), listid: list_id)

    if result['ret'].to_i.zero?
      people_to_track.map(&:mark_as_tracked!)
      inc :member_count, people_to_track.size

      tencent_agent.info %{Tracked users "#{user_openids.join(',')}" by list}

      remaining_people

    else
      if result['ret'].to_i == 5 and result['errcode'].to_i == 98
        # Just return all people when list limitation of maximized members reached
        people
      else
        raise TencentError.new(%{Failed to track users "#{user_openids.join(',')}" by list}, result)
      end
    end
  end

  def capacity
    LIST_MAX_MEMBER_COUNT - member_count
  end

  private

  def delete_tencent_list
    result = tencent_agent.post('api/list/delete', listid: list_id)
    if result['ret'].to_i.zero?
      tencent_agent.info %{Deleted list "#{name}"}
      true
    else
      raise TencentError.new(%{Failed to delete list "#{name}"}, result)
    end
  end
end
