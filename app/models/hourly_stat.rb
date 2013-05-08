class HourlyStat
  include Mongoid::Document

  field :word
  field :group_id, type: Integer
  field :date, type: Date
  field :stats, type: Array # [{hour: 0, count: 1}, {hour: 1, count: 2}, {hour: 10, count: 0}]
end
