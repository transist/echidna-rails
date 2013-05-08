class City
  include Mongoid::Document

  field :name
  field :tier

  validates :name, presence: true

  belongs_to :group
end
