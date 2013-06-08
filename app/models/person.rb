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
  field :profile, type: Hash
  field :tracked, type: Boolean, default: false
  field :spam, type: Boolean, default: false
  field :seed_level, type: Integer
  field :all_followings_sampled, type: Boolean, default: false

  validates :gender, inclusion: { in: GENDERS }

  index({ target_source: 1, target_id: 1}, { unique: true })
  index({ famous: 1 })
  index({ tracked: 1 })
  index({ seed_level: 1, all_followings_sampled: 1 })

  has_many :tweets
  belongs_to :city
  belongs_to :seed_person, class_name: 'Person'
  has_and_belongs_to_many :groups

  def spam!
    update_attribute :spam, true
    self.tweets.map(&:spam!)
  end

  def all_followings_sampled!
    update_attribute :all_followings_sampled, true
  end
end
