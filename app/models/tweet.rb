class Tweet
  include Mongoid::Document

  field :target_source
  field :target_id
  field :content
  field :posted_at, type: Time
  field :words, type: Array
  field :spam, type: Boolean, default: false

  validates :content, presence: true

  belongs_to :person

  before_create :init_words
  after_create :update_stats

  index({ target_source: 1, target_id: 1 }, { unique: true })

  def spam!
    self.update_attribute :spam, true
    self.words.each do |word|
      person.groups.each do |group|
        DailyStat.remove(word, group, self)
        HourlyStat.remove(word, group, self)
      end
    end
  end

  private

  def init_words
    self.words = Echidna::Stopwords.reject(Rseg.segment(filter_at_username(Nokogiri::HTML(content).text)))
  end

  def filter_at_username(content)
    content.gsub(/@[^ ]*/, '')
  end

  def update_stats
    self.words.each do |word|
      person.groups.each do |group|
        DailyStat.record(word, group, self)
        HourlyStat.record(word, group, self)
      end
    end
  end
end
