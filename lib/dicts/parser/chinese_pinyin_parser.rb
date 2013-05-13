# coding: utf-8
module Dicts
  module Parser
    class ChinesePinyinParser
      DICT_FILENAME = 'dicts/Mandarin.dat'

      def parse
        File.open(DICT_FILENAME, 'r') do |file|
          file.each_line do |line|
            char_hex, pinyin = line.split(' ')
            # convert from Unicode codepoint to Unicode character
            char = [char_hex.hex].pack("U")
            Homonym.add_pinyin(char, pinyin)
          end
        end
        Homonym.prepare_pinyin_for_words
      end
    end
  end
end
