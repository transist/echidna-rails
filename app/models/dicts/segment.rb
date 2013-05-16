# coding: utf-8
class Segment
  class <<self
    def get(text, options={})
      Rseg.segment(text).reject { |word| Stopword.is?(word) }
    end
  end
end
