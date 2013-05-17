class Tweet
  include Mongoid::Document

  field :target_id
  field :content
  field :posted_at, type: Time

  validates :content, presence: true

  belongs_to :person

  after_create :update_stats

  def extract_words
    Stopword.filter(Segment.get(content))
  end

  private

  def update_stats
    extract_words.each do |word|
      person.groups.each do |group|
        DailyStat.record(word, group, posted_at.to_date)
        HourlyStat.record(word, group, posted_at)
      end
    end
  end
end
