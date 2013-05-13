# coding: utf-8
class Homonym
  class <<self
    def get(word)
      pinyins = word.each_char.inject([]) { |result, char| result = result.multiple(pinyins(char)); result }
      pinyins.inject([]) { |homonyms, pinyin| homonyms += $redis.smembers(pinyin_to_word_key(pinyin)) }.reject { |homonym| homonym == word }
    end

    def add_pinyin(char, pinyin)
      $redis.sadd char_to_pinyin_key(char), pinyin
      $redis.sadd pinyin_to_char_key(pinyin), char
    end

    def prepare_pinyin_for_words
      $redis.smembers("words").each do |word|
        pinyins = word.each_char.inject([]) { |result, char| result = result.multiple(pinyins(char)); result }
        pinyins.each do |pinyin|
          $redis.sadd(pinyin_to_word_key(pinyin), word)
        end
      end
    end

    def flush
      $redis.keys("c2py/*").each do |key|
        $redis.del key
      end
      $redis.keys("py2c/*").each do |key|
        $redis.del key
      end
      $redis.keys("py2w/*").each do |key|
        $redis.del key
      end
    end

    private
    def pinyins(char)
      $redis.smembers(char_to_pinyin_key(char))
    end

    def char_to_pinyin_key(char)
      "c2py/#{char}"
    end

    def pinyin_to_char_key(pinyin)
      "py2c/#{pinyin}"
    end

    def pinyin_to_word_key(pinyin)
      "py2w/#{pinyin}"
    end
  end
end
