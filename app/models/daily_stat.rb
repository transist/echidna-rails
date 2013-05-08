class DailyStat
  include Mongoid::Document

  field :word
  field :group_id, type: Integer
  field :date, type: Date
  field :stats, type: Array
end
