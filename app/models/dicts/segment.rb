# coding: utf-8
class Segment
  class <<self
    def get(text, options={})
      algorithm = RMMSeg::Algorithm.new(text)
      segments = []
      loop do
        token = algorithm.next_token
        break if token.nil?
        if options[:optimize]
          segments << token.text unless Stopword.is?(token.text)
        else
          segments << token.text
        end
      end
      if options[:optimize]
        segments.uniq.sort
      else
        segments
      end
    end
  end
end
