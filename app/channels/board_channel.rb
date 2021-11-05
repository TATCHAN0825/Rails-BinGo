class BoardChannel < ApplicationCable::Channel
  def subscribed
    @board = Board.find(params[:board])
    stream_from "board_channel_#{params[:board]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def ready(args)
    ready = args['ready']
    card = @board.card_for(current_user)
    if ready === true
      card.update(ready: true)
    elsif ready === false
      card.update(ready: false)
    end
    if @board.cards.where(ready: false).size <= 0 # 準備完了してない人が0人以下だったら
      @board.update(phase: :ready)

      @board.update(current: @board.users.first)

      BoardBroadcastJob.perform_later(@board.id, { type: 'your_turn', id: @board.current.id })
    end

    BoardBroadcastJob.perform_later(@board.id, { type: 'update_ready', user_id: current_user.id, ready: ready })
  end

  def lottery_start_request
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

    # ないとうごかない
    @board = Board.find(@board.id)

    BoardBroadcastJob.perform_later(@board.id, { type: 'lottery_start', numbers: numbers.shuffle })
    BoardBroadcastJob.set(wait: rand(3..8).seconds).perform_later(@board.id, { type: 'lottery_stop', result: result, user: @board.current.id })
  end

  def next_user
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
