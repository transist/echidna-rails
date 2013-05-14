class Tweet
  include Mongoid::Document

  field :target_id
  field :content
  field :posted_at, type: Time

  validates :content, presence: true

  belongs_to :person

  after_save :update_stats

  def extract_words
    Stopword.filter(Segment.get(content))
  end

  private

  def update_stats
    posted_on = posted_at.to_date

    extract_words.each do |word|
      person.groups.each do |group|
        HourlyStat.create(word: word, group: group, date: posted_on,
                         stats: {})
        DailyStat.create(word: word, group: group, date: posted_on.beginning_of_month,
                        stats: {})
      end
    end
  end
end
