class Panel
  include Mongoid::Document

  field :age_ranges, type: Array
  field :gender

  belongs_to :user
  has_and_belongs_to_many :cities
  has_and_belongs_to_many :groups

  before_save :remove_empty_age_range, :set_groups

  def z_scores(time)
    DailyStat.top_trends(self)
  end

  def to_s
    '%s %s %s' % [age_ranges.join(', '), gender, cities.map(&:name)]
  end

  def start_years
    self.age_ranges.map { |age_range| age_range.split(' - ').first }
  end

  def end_years
    self.age_ranges.map { |age_range| age_range.split(' - ').last }
  end

  private
  def remove_empty_age_range
    self.age_ranges.reject! { |age_range| age_range.blank? }
  end

  def set_groups
    self.group_ids = Group.all_for_panel(self).map(&:id)
  end
end
