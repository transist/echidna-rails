# coding: utf-8

# stopwords are meaningless words
class Stopword
  class <<self
    # select meaningful words in the list of words
    # TODO: rename reject
    def filter(words)
      # for every word that is not single character and not a username and is not a stopword
      words.select { |word| !single_character?(word) && !username?(word) && !is?(word) }
    end

    # add a stopword (TODO: rename)
    def add(word)
      $redis.sadd key, word
    end
    
    # remove all the stopwords by removing the set
    def flush
      $redis.del key
    end

    # is this a stopword?
    def is?(word)
      $redis.sismember key, word
    end

    # is this a single character word?
    def single_character?(word)
      word.length == 1
    end

    # tencent usernames start with @
    def username?(word)
      word[0] == '@'
    end

    private
    def key
      "stopwords"
    end
  end
end
