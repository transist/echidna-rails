class BaseStat
  def self.aggregate(history_stats, current_stats, user, limit)
    positive_stats = []
    negative_stats = []
    zero_stats = []

    current_stats.each { |word, current_stat|
      unless user.has_stopword? word
        z_score = FAZScore.new(0.5, history_stats[word]).score(current_stat)
        stat = {word: word, z_score: z_score.round(2), current_stat: current_stat}
        if z_score > 0
          positive_stats << stat
        elsif z_score < 0
          negative_stats << stat
        else z_score == 0
          zero_stats << stat
        end
      end
    }
    {
      positive_stats: positive_stats.sort_by { |stat| -stat[:z_score] }[0...limit],
      zero_stats: zero_stats.sort_by { |stat| -stat[:current_stat] }[0...limit],
      negative_stats: negative_stats.sort_by { |stat| stat[:z_score] }[0...limit]
    }
  end
end
