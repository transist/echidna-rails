class Group
  include Mongoid::Document

  GET_GROUP_ID_URL = 'http://echidna.transi.st:62300/group_id'
  Z_SCORES_URL = 'http://echidna.transi.st:62300/z-scores'

  field :start_birth_year, type: Integer
  field :end_birth_year, type: Integer
  field :gender, type: String
  field :cities, type: Array # ["上海", "北京"]

  validates :gender, inclusion: { in: %w(Male Female Both) }

  belongs_to :user
  has_many :persons

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
    '%s - %s %s %s' % [start_birth_year, end_birth_year, gender, cities.join(',')]
  end
end
