class City
  include Mongoid::Document

  embedded_in :panel

  field :name
  field :tier

  validates :name, presence: true, uniqueness: true
end
