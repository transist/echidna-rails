class Person
  include Mongoid::Document

  GENDERS = %w(male female both)
  BIRTH_YEARS = [
    {start: 1947, end: 1953},
    {start: 1954, end: 1960},
    {start: 1961, end: 1967},
    {start: 1968, end: 1974},
    {start: 1975, end: 1981},
    {start: 1982, end: 1988},
    {start: 1989, end: 1995},
    {start: 1996, end: 2002},
    {start: 2003, end: 2009},
    {start: 2010, end: 2013}
  ]

  field :target_source, type: String
  field :target_id, type: String
  field :birth_year, type: Integer
  field :gender, type: String

  validates :gender, inclusion: { in: GENDERS }

  has_many :tweets
  belongs_to :city
  has_and_belongs_to_many :groups
end
