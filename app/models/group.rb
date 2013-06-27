class Group
  include Mongoid::Document

  field :start_birth_year, type: Integer
  field :end_birth_year, type: Integer
  field :gender, type: String

  validates :gender, inclusion: { in: Person::GENDERS }, allow_nil: true

  belongs_to :user
  belongs_to :city
  has_and_belongs_to_many :people
  has_and_belongs_to_many :panels

  index({ start_birth_year: 1, end_birth_year: 1, gender: 1, city_id: 1 }, { unique: true })

  def self.all_for_person(person)
    where(
      :start_birth_year.lte => person.birth_year,
      :end_birth_year.gte => person.birth_year,
      :gender.in => [person.gender, 'both'],
      city_id: person.city_id
    )
  end

  def self.all_for_panel(panel)
    criteria = if panel.start_years.empty? && panel.end_years.empty?
                 where(start_birth_year: nil, end_birth_year: nil)
               else
                 where(:start_birth_year.in => panel.start_years,
                       :end_birth_year.in => panel.end_years)
               end

    criteria = if panel.gender.blank?
                 criteria.where(gender: nil)
               else
                 criteria.where(gender: panel.gender)
               end

    criteria = if panel.cities.empty?
                 criteria.where(city_id: nil)
               else
                 criteria.where(:city_id.in => panel.city_ids)
               end
  end

  def add_person(person)
    people << person
  end

  def z_scores(time)
    DailyStat.top_trends(self.id)
  end

  def to_s
    birth_year = if start_birth_year && end_birth_year
                   '%s - %s' % [start_birth_year, end_birth_year]
                 else
                   'All birth years'
                 end
    '%s %s %s' % [birth_year, gender || 'All genders', city ? city.name : 'All cities']
  end
end
