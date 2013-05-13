# coding: utf-8
module Dicts
  module Parser
    class StopwordsParser
      DICT_FILENAMES= %w(dicts/chinese_stopwords.txt dicts/english_stopwords.txt)

      def parse
        DICT_FILENAMES.each do |filename|
          File.open(filename, 'r') do |file|
            file.each_line do |line|
              Stopword.add(line.strip)
            end
          end
        end
      end
    end
  end
end
