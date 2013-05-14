# coding: utf-8
module Dicts
  module Parser
    class HypernymsDictParser
      DICT_FILENAME = 'dicts/hypernyms.dic'

      def parse
        File.open(DICT_FILENAME, 'r') do |file|
          hypernyms = []
          last_level = 0
          last_value = ''

          file.each_line do |line|
            level = detect_level(line.chomp)
            if last_level + 1 == level
              hypernyms.push last_value
              last_level = level
            elsif last_level == level + 1
              hypernyms.pop
              last_level = level
            end
            last_value = line.strip

            Hypernym.set(line.strip, hypernyms.last)
          end
        end
      end

      private
      def detect_level(str)
        count = 0
        str.chars.each do |c|
          if c == ' '
            count += 1
          else
            break
          end
        end
        count / 2
      end

    end
  end
end
