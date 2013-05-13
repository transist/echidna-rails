class Tweet
  include Mongoid::Document

  field :target_id
  field :content
  field :posted_at, type: Time

  validates :content, presence: true

  belongs_to :person
end
