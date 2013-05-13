module Dicts
  module Parser
    class WordsDictParser
      DICT_FILENAME = 'dicts/words.dic'

      def parse
        File.open(DICT_FILENAME, 'r') do |file|
          file.each_line do |line|
            Word.add(line.split(' ').last)
          end
        end
      end
    end
  end
end
