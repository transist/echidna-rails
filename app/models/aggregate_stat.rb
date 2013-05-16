class AggregateStat
  def self.words_scores(history_stats, current_stats)
    h_stats = history_stats.inject({}) do |h_stats, single_stats|
      single_stats.each do |word, stats|
        h_stats[word] ||= []
        h_stats[word] << stats
      end
      h_stats
    end
    c_stats = current_stats.inject({}) do |c_stats, single_stats|
      single_stats.each do |word, stats|
        c_stats[word] ||= 0
        c_stats[word] += stats
      end
      c_stats
    end
    c_stats.map { |word, c_stat|
      {word: word, z_score: FAZScore.new(0.5, h_stats[word].transpose.map { |stats| stats.reduce(&:+) }).score(c_stat)}
    }.sort_by { |stat| -stat[:z_score] }
  end
end
