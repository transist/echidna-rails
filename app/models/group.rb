class Group
  include Mongoid::Document

  field :age_range, type: String
  field :gender, type: String
  field :tier_id, type: String

  belongs_to :user

  def tier
    Tier.find(tier_id)
  end

  def to_s
    '%s %s %s' % [tier['name'], age_range, gender]
  end
end
