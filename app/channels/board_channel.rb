class BoardChannel < ApplicationCable::Channel
  def subscribed
    @board = Board.find(params[:board])
    stream_from "board_channel_#{params[:board]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def ready(args)
    @board = Board.find(@board.id)

    ready = args['ready']
    card = @board.card_for(current_user)
    if ready === true
      card.update(ready: true)
    elsif ready === false
      card.update(ready: false)
    end
    if @board.cards.where(ready: false).size <= 0 # 準備完了してない人が0人以下だったら
      @board.update(phase: :ready)
      @board.update(phase: :game)

      @board.update(current: @board.users.first)

      #BoardBroadcastJob.perform_later(@board.id, { type: 'your_turn', id: @board.current.id })
    end

    #BoardBroadcastJob.perform_later(@board.id, { type: 'update_ready', user_id: current_user.id, ready: ready })
    BoardBroadcastJob.perform_later(@board.id, { type: 'reload' })
  end

  def lottery_start_request
    @board = Board.find(@board.id)

    numbers = [*1..75]

    @board.number_open_logs.each do |number_open_log|
      numbers.delete(number_open_log.value);
    end

    if numbers.size <= 0
      BoardBroadcastJob.perform_later(@board.id, { type: 'error', message: 'もう出ないよぉ...(しょたぼ)' })
    end

    result = numbers.sample

    @board.cards.each do |card|
      card.numbers.each do |number|
        if result == number.value
          number.update(open: true)
        end
      end
    end

    @board.number_open_logs.create!(value: result)

    BoardBroadcastJob.perform_later(@board.id, { type: 'lottery_start', numbers: numbers.shuffle })
    BoardBroadcastJob.set(wait: rand(3..8).seconds).perform_later(@board.id, { type: 'lottery_stop', result: result, user: @board.current.id })
    #BoardBroadcastJob.perform_later(@board.id, { type: 'lottery_stop', result: result, user: @board.current.id })
  end

  def next_user
    @board = Board.find(@board.id)

    unless @board.phase == 'game'
      return
    end

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

    BoardBroadcastJob.perform_later(@board.id, { type: 'turn', name: @board.current.name })
    BoardBroadcastJob.perform_later(@board.id, { type: 'your_turn', id: @board.current.id })
  end

  def bingo(data)
    @board = Board.find(@board.id)

    user = User.find(data['user'])

    @board.update(phase: :end, current: nil, winner: user)

    BoardBroadcastJob.perform_later(@board.id, { type: 'winner', name: user.name })

    seconds = 10
    #BoardDestroyJob.set(wait: seconds.seconds).perform_later(@board.id)
    BoardBroadcastJob.perform_later(@board.id, { type: 'close', seconds: seconds })
    BoardCloseJob.set(wait: seconds.seconds).perform_later(@board.id)
  end

  def chat_send(data)
    @board = Board.find(@board.id)

    message = data['message']

    current_user.chats.create!(board: @board, content: message)
  end
end
