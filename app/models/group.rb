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
  has_and_belongs_to_many :people

  def self.all_for_person(person)
    where(
      :start_birth_year.lte => person.birth_year,
      :end_birth_year.gte => person.birth_year,
      :gender.in => [person.gender, 'both'],
      city_id: person.city_id
    )
  end

  def add_person(person)
    people << person
  end

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
    '%s - %s %s %s' % [start_birth_year, end_birth_year, gender, city.name]
  end
end
