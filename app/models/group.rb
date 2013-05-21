class Group
  include Mongoid::Document

  field :start_birth_year, type: Integer
  field :end_birth_year, type: Integer
  field :gender, type: String

  validates :gender, inclusion: { in: Person::GENDERS }

  belongs_to :user
  belongs_to :city
  has_and_belongs_to_many :people
  has_and_belongs_to_many :panels

  def self.all_for_person(person)
    where(
      :start_birth_year.lte => person.birth_year,
      :end_birth_year.gte => person.birth_year,
      :gender.in => [person.gender, 'both'],
      city_id: person.city_id
    )
  end

  def self.all_for_panel(panel)
    where(
      :start_birth_year.in => panel.start_years,
      :end_birth_year.in => panel.end_years,
      :gender.in => [panel.gender, 'both'],
      :city_id.in => panel.cities.map(&:id)
    )
  end

  def add_person(person)
    people << person
  end

  def z_scores(time)
    DailyStat.top_trends(self.id)
  end

  def to_s
    '%s - %s %s %s' % [start_birth_year, end_birth_year, gender, city.name]
  end
end
