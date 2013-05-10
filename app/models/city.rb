class City
  include Mongoid::Document

  field :name
  field :tier

  validates :name, presence: true, uniqueness: true
end
