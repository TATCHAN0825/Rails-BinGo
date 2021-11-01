class BoardChannel < ApplicationCable::Channel
  def subscribed
    stream_from "board_channel_#{params[:board]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def ready(args)
    board = Board.find(args['boardid'])
    ready = args['ready']
    card = board.card_for(current_user)
    if ready === true
      card.update(ready: true)
    elsif ready === false
      card.update(ready: false)
    end
    if board.cards.where(ready: false).size <= 0 # 準備完了してない人が0人以下だったら
      board.update(phase: :ready)
    end

    BoardBroadcastJob.perform_later(board.id, { type: 'update_ready', user_id: current_user.id, ready: ready })
  end
end
