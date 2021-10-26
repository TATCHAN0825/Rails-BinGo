class Number < ApplicationRecord
  belongs_to :card

  validates :id, uniqueness: { scope: [:row, :column] }
  validates :value, numericality: { in: 0..75 }, allow_nil: true
  validates :open, inclusion: { in: [true, false] }
  validates :column, presence: true, numericality: { in: 0..4 }
  validates :row, presence: true, numericality: { in: 0..4 }
end
