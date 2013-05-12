class City
  include Mongoid::Document

  has_and_belongs_to_many :panels
  has_many :groups

  field :name
  field :tier

  validates :name, presence: true, uniqueness: true
end
