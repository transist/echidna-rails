class Person
  include Mongoid::Document

  field :target_source, type: String
  field :target_id, type: String
  field :birth_year, type: Integer
  field :gender, type: String

  has_mnay :tweets
  belongs_to :city
  belongs_to :group
end
