# coding: utf-8
module Dicts
  module Parser
    class SynonymsDictParser
      DICT_FILENAME = 'dicts/10000_synonyms.txt'
      #DICT_FILENAME = 'dicts/synonyms.txt'

      def parse
        File.open(DICT_FILENAME, 'r') do |file|
          file.each_line do |line|
            word1, word2 = line.strip.split(',')
            #word1, word2 = line.strip.split('—')
            Synonym.set(word1, word2)
          end
        end
      end
    end
  end
end
