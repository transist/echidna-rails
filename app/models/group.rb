class Group
  include Mongoid::Document

  GET_GROUP_ID_URL = 'http://echidna.transi.st:62300/group_id'
  Z_SCORES_URL = 'http://echidna.transi.st:62300/z-scores'

  field :start_birth_year, type: Integer
  field :end_birth_year, type: Integer
  field :gender, type: String

  validates :gender, inclusion: { in: Person::GENDERS }

  belongs_to :user
  belongs_to :city
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
    DailyStat.top_trends(self.id)
  end

  def to_s
    '%s - %s %s %s' % [start_birth_year, end_birth_year, gender, city.name]
  end
end
