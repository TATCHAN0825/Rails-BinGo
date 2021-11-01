class BoardChannel < ApplicationCable::Channel
  def subscribed
    stream_from "board_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def ready(args)
    board = current_user.cards.find_by(user_id: current_user.id).board
    ready = args['ready']
    if ready === true
      current_user.cards.where(user_id: current_user.id, board_id: board.id).update(ready: true)
    elsif ready === false
      current_user.cards.where(user_id: current_user.id, board_id: board.id).update(ready: false)
    end
    if board.cards.where(ready: false).size <= 0 # 準備完了してない人が0人以下だったら
      board.update(phase: :ready)
    end

    BoardBroadcastJob.perform_later({ type: 'update_ready', user_id: current_user.id, ready: ready })
  end
end
