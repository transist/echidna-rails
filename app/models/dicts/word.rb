class Word
  class <<self
    def add(word)
      $redis.sadd key, word
    end

    def exist?(word)
      $redis.sismember key, word
    end

    def flush
      $redis.del key
    end

    private
    def key
      "words"
    end
  end
end
