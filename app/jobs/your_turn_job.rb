class YourTurnJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @board = Board.find(args[0])

    next_current = false
    current = nil
    @board.users.each do |user|
      current = user if next_current
      if user == @board.current
        next_current = true
      end
    end

    current = @board.users.first if current.nil?
    @board.update(current: current)

    BoardBroadcastJob.perform_later(@board.id, { type: 'your_turn', id: @board.current.id })
  end
end
