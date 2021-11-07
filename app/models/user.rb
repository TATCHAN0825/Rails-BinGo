class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, presence: true, uniqueness: true
  has_many :cards, dependent: :destroy
  has_many :boards
  has_many :chats, dependent: :destroy

  # 参加して終わったBoards
  def joined_boards
    boards = []
    Board.where(phase: :close).each do |board|
      boards << board if board.users.include?(self)
    end
    boards
  end

  def win_boards
    boards = []
    joined_boards.each do |board|
      boards << board if board.winner == self
    end
    boards
  end

  def lose_boards
    boards = []
    joined_boards.each do |board|
      boards << board unless board.winner == self
    end
    boards
  end
end
