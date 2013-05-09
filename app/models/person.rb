class Person
  GENDERS = %w(male female both)
  include Mongoid::Document

  field :target_source, type: String
  field :target_id, type: String
  field :birth_year, type: Integer
  field :gender, type: String

  validates :gender, inclusion: { in: GENDERS }

  has_many :tweets
  belongs_to :city
  belongs_to :group
end
