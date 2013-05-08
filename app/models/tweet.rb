class Tweet
  include Mongoid::Document

  field :content
  field :url

  validates :content, :url, presence: true

  belongs_to :person
end
