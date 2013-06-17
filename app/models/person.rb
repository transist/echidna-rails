class Person
  include Mongoid::Document

  GENDERS = %w(male female both)
  BIRTH_YEARS = [
    [1947, 1953],
    [1954, 1960],
    [1961, 1967],
    [1968, 1974],
    [1975, 1981],
    [1982, 1988],
    [1989, 1995],
    [1996, 2002],
    [2003, 2009],
    [2010, 2013]
  ]

  field :target_source, type: String
  field :target_id, type: String
  field :target_name, type: String
  field :famous, type: Boolean, default: false
  field :hot, type: Boolean, default: false
  field :birth_year, type: Integer
  field :gender, type: String
  field :profile, type: Hashie::Mash
  field :spam, type: Boolean, default: false
  field :seed_level, type: Integer
  field :all_followings_sampled, type: Boolean, default: false

  validates :gender, inclusion: { in: GENDERS }

  index({ target_source: 1, target_id: 1}, { unique: true })
  index({ famous: 1 })
  index({ seed_level: 1, all_followings_sampled: 1 })
  index({ birth_year: 1, gender: 1, city_id: 1 })
  index({ gender: 1, city_id: 1 })
  index({ city_id: 1, birth_year: 1 })

  has_many :tweets
  belongs_to :city
  belongs_to :seed_person, class_name: 'Person'
  belongs_to :tencent_list, index: true
  has_and_belongs_to_many :groups

  scope :untracked, where(tencent_list: nil)
  scope :has_birth_year, ne(birth_year: 0)
  scope :has_gender, ne(gender: 'both')
  scope :has_city, ne(city_id: nil)

  def self.stats
    stats = Hashie::Mash.new
    stats.people_count = Person.count

    stats.has_birth_year = Person.has_birth_year.count
    stats.has_gender = Person.has_gender.count
    stats.has_city = Person.has_city.count

    stats.has_birth_year_gender = Person.has_birth_year.has_gender.count
    stats.has_birth_year_city = Person.has_birth_year.has_city.count
    stats.has_gender_city = Person.has_gender.has_city.count

    stats.has_birth_year_gender_city = Person.has_birth_year.has_gender.has_city.count

    stats.has_birth_year_percentage = stats.has_birth_year / stats.people_count.to_f
    stats.has_gender_percentage = stats.has_gender / stats.people_count.to_f
    stats.has_city_percentage = stats.has_city / stats.people_count.to_f

    stats.has_birth_year_gender_percentage = stats.has_birth_year_gender / stats.people_count.to_f
    stats.has_birth_year_city_percentage = stats.has_birth_year_city / stats.people_count.to_f
    stats.has_gender_city_percentage = stats.has_gender_city / stats.people_count.to_f

    stats.has_birth_year_gender_city_percentage = stats.has_birth_year_gender_city / stats.people_count.to_f

    stats
  end

  def spam!
    update_attribute :spam, true
    self.tweets.map(&:spam!)
  end

  def all_followings_sampled!
    update_attribute :all_followings_sampled, true
  end

  def mark_as_tracked!(tencent_list)
    update_attribute :tencent_list_id, tencent_list.id
  end
end
