class Group
  include Mongoid::Document

  GET_GROUP_ID_URL = 'http://echidna.transi.st:62300/group_id'
  Z_SCORES_URL = 'http://echidna.transi.st:62300/z-scores'

  field :age_range, type: String
  field :gender, type: String
  field :tier_id, type: String

  belongs_to :user

  def tier
    Tier.find(tier_id)
  end

  def get_group_id
    @group_id ||= begin
                    response = Faraday.get(
                      GET_GROUP_ID_URL,
                      tier_id: tier_id,
                      age_range: age_range,
                      gender: gender
                    )
                    MultiJson.load(response.body)['id']
                  end
  end

  def z_scores(time)
    response = Faraday.get(
      Z_SCORES_URL,
      interval: :day,
      time: time,
      group_id: get_group_id
    )
    MultiJson.load(response.body)[get_group_id]
  end

  def to_s
    '%s %s %s' % [tier['name'], age_range, gender]
  end
end
