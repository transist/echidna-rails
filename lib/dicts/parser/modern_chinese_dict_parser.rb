# coding: utf-8
require 'msworddoc-extractor'

module Dicts
  module Parser
    class ModernChineseDictParser
      DICT_FILENAME = 'dicts/modern_chinese_dict_5_edition.doc'

      def parse
        MSWordDoc::Extractor.load(DICT_FILENAME) do |doc|
          doc.whole_contents.split("\n").each do |content|
            if content =~ /【(.*)?】/
              p $1
            end
          end
        end
      end
    end
  end
end
