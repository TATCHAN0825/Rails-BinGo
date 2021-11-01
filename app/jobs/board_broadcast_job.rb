class BoardBroadcastJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ActionCable.server.broadcast "board_channel_#{args[0]}", args[1]
  end
end
