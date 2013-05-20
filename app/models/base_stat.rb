class BaseStat
  def self.aggregate(history_stats, current_stats, user, limit)
    current_stats.map { |word, current_stat|
      {word: word, z_score: FAZScore.new(0.5, history_stats[word]).score(current_stat), current_stat: current_stat}
    }.reject { |stat| user.has_stopword? stat[:word] }.sort_by { |stat| -stat[:z_score] }[0...limit]
  end
end
