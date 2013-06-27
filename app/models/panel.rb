class Panel
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :age_ranges, type: Array
  field :gender
  field :period
  field :freq_limit, type: Integer

  validates :name, presence: true

  belongs_to :user, index: true
  has_and_belongs_to_many :cities
  has_and_belongs_to_many :groups

  before_save :remove_empty_age_range, :set_groups

  index({ user_id: 1, created_at: -1 })

  def start_years
    self.age_ranges.map { |age_range| age_range.split(' - ').first }
  end

  def end_years
    self.age_ranges.map { |age_range| age_range.split(' - ').last }
  end

  def age_ranges_label
    case age_ranges
    when []
      'Age all'
    else
      age_ranges.map do |age_range|
        age_range == '0 - 0' ? 'Age unknown' : age_range
      end.join(', ')
    end
  end

  def gender_label
    case gender
    when 'unknown'
      'Gender unknown'
    when ''
      'Gender all'
    else
      gender
    end
  end

  def cities_label
    case cities
    when []
      'City all'
    else
      cities.map(&:label).join(', ')
    end
  end

  private
  def remove_empty_age_range
    self.age_ranges.reject! { |age_range| age_range.blank? }
  end

  def set_groups
    self.group_ids = Group.all_for_panel(self).map(&:id)
  end
end
