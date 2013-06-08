module Hashie
  class Mash
    def mongoize
      object.to_hash
    end

    class << self
      def mongoize(object)
        object.to_hash
      end

      def demongoize(object)
        Mash.new(object)
      end
    end
  end
end
