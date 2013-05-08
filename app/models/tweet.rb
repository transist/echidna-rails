class Tweet
  include Mongoid::Document

  field :content
  field :url

  belongs_to :person
end
