class Panel
  include Mongoid::Document

  belongs_to :user
  embeds_many :cities
  field :age_range, type: Array
  field :gender

  def city_ids=(city_ids)
    self.cities = city_ids.map { |city_id|
      if city_id.present?
        City.find(city_id)
      end
    }.compact
  end

  def city_ids
    cities.map(&:id)
  end

  def to_s
    '%s %s %s' % [age_range, gender, cities.map(&:name)]
  end
end
