# coding: utf-8
class Synonym
  class <<self
    def get(text)
      $redis.smembers key(text)
    end

    def set(word1, word2)
      $redis.sadd key(word1), word2
      $redis.sadd key(word2), word1
    end

    def flush
      $redis.keys("synonym/*").each do |key|
        $redis.del key
      end
    end

    private
    def key(text)
      "synonym/#{text}"
    end
  end
end
