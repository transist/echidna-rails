class Panel
  include Mongoid::Document

  field :age_ranges, type: Array
  field :gender

  belongs_to :user
  embeds_many :cities

  before_save :remove_empty_values

  def city_ids=(city_ids)
    self.cities = city_ids.map { |city_id|
      if city_id.present?
        City.find(city_id)
      end
    }
  end

  def city_ids
    cities.map(&:id)
  end

  def to_s
    '%s %s %s' % [age_ranges.join(', '), gender, cities.map(&:name)]
  end

  private

  def remove_empty_values
    self.cities.reject! { |city_id| city_id.blank? }
    self.age_ranges.reject! { |city_id| city_id.blank? }
  end
end
