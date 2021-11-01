class Board < ApplicationRecord
  has_many :cards, dependent: :destroy
  belongs_to :leader, class_name: 'User', optional: true

  enum phase: %i[wait ready game end] # wait: 準備完了待機中, ready: 全員準備完了, game: ゲーム中, end: ゲーム終了

  validates :name, presence: true, uniqueness: true
end
