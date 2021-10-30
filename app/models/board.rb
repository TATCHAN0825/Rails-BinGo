class Board < ApplicationRecord
  has_many :cards, dependent: :destroy
  belongs_to :leader, class_name: 'User', optional: true

  validates :name, presence: true, uniqueness: true
end
