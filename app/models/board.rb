class Board < ApplicationRecord
  has_many :cards, dependent: :destroy
  has_many :number_open_logs, dependent: :destroy
  belongs_to :leader, class_name: 'User', optional: true
  belongs_to :current, class_name: 'User', optional: true

  enum phase: %i[wait ready game end] # wait: 準備完了待機中, ready: 全員準備完了, game: ゲーム中, end: ゲーム終了

  validates :name, presence: true, uniqueness: true

  after_update :send_phase

  def users
    self.cards.map { |card| card.user }
  end

  def card_for(user)
    self.cards.find_by(user_id: user)
  end

  private

  def send_phase
    BoardBroadcastJob.perform_later(self.id, { type: 'phase_changed', phase: self.phase_before_type_cast }) if self.saved_change_to_phase?
  end
end
