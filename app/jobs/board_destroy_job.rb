class BoardDestroyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    board = Board.find(args[0])
    board.destroy!
  end
end
