class Card < ApplicationRecord
  belongs_to :user
  belongs_to :board
  has_many :numbers, dependent: :destroy

  after_create :make_card
  after_create :send_join

  private

  def make_card
    5.times do |column|
      case column
      when 0 # B
        range = 1..15
      when 1 # I
        range = 16..30
      when 2 # N
        range = 31..45
      when 3 # G
        range = 46..60
      when 4 # O
        range = 61..75
      else
        raise StandardError
      end
      values = []
      for i in range do
        values << i
      end
      values.shuffle!
      5.times do |row|
        self.numbers.create!(value: column == 2 && row == 2 ? nil : values.shift, column: column, row: row)
      end
    end
  end

  def send_join
    
  end
end
