class BoardCloseJob < ApplicationJob
  queue_as :default

  def perform(*args)
    board = Board.find(args[0])
    board.update(phase: :close)
    BoardBroadcastJob.perform_later(board.id, { type: 'closed' })
  end
end
