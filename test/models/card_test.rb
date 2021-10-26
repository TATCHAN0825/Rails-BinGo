require "test_helper"

class CardTest < ActiveSupport::TestCase
  test "make_card" do
    card = Card.create!(player: players(:one), board: boards(:one))
    numbers = card.numbers
    puts '| B | I | N | G | O |'
    str = ['|', '|', '|', '|', '|']
    5.times do |column|
      5.times do |row|
        number = numbers.find_by(column: column, row: row)
        assert_not_nil(number)
        if column == 2 && row == 2 # FREE
          assert_nil(number.value)
        else
          assert_not_nil(number.value)
        end
        str[row] += "#{number.value.to_s.ljust(3)}|"
      end
    end
    str.each do |s|
      puts s
    end
  end
end
