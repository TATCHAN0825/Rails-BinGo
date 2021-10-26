class Player < ApplicationRecord
  has_many :cards, dependent: :destroy
end
