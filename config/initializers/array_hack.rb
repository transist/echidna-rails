# coding: utf-8
class Array
  def multiple(other)
    return other if self.empty?

    results = []
    self.each do |self_ele|
      other.each do |other_ele|
        results << self_ele + other_ele
      end
    end
    results
  end
end
