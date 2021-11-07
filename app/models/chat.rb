class Chat < ApplicationRecord
  belongs_to :board
  belongs_to :user

  validates :content, presence: true

  after_create :send_chat

  private

  def send_chat
    # TODO クライアントサイドでエスケープすべき？
    BoardBroadcastJob.perform_later(self.board.id, { type: 'chat', name: ERB::Util.html_escape(self.user.name), message: ERB::Util.html_escape(self.content) })
  end
end
