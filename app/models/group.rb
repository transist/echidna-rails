class Group
  include Mongoid::Document

  field :age_range, type: String
  field :gender, type: String
  field :city, type: String

  belongs_to :user

  def to_s
    '%s %s %s' % [city, age_range, gender]
  end
end
