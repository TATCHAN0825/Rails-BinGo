class NumberOpenLog < ApplicationRecord
  belongs_to :board

  validates :value, presence: true, numericality: true
end
