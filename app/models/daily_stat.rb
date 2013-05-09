class DailyStat
  include Mongoid::Document

  field :word
  field :group_id, type: Integer
  field :date, type: Date
  field :stats, type: Array # [{day: 0, count: 1}, {day: 1, count: 2}, {day: 10, count: 0}]
end
