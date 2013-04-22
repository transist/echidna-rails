class Tier
  TIERS_URL = 'http://localhost:62306/tiers'

  def self.all
    @tiers ||= begin
                 response = Faraday.get(TIERS_URL)
                 MultiJson.load(response.body)
               end
  end

  def self.find(id)
    all.find do |tier|
      tier['id'] == id.to_s
    end
  end
end
