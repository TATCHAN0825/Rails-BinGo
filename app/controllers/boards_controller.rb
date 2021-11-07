class BoardsController < ApplicationController
  before_action :authenticate_user!, except: %i[index]
  before_action :set_board, only: [:show, :edit, :update, :destroy, :join]

  # GET /boards
  def index
    @boards = Board.where.not(phase: :close)
  end

  # GET /boards/1
  def show
    unless @board.cards.find_by(user_id: current_user.id)
      flash[:alert] = '参加してない'
      redirect_to boards_path
    end
  end

  # GET /boards/new
  def new
    @board = Board.new
  end

  # GET /boards/1/edit
  def edit
    unless @board.leader == current_user
      flash[:alert] = 'リーダー以外は編集できません'
      redirect_to boards_path
    end
  end

  # POST /boards
  def create
    @board = Board.new(board_params)
    @board.leader = current_user
    card = current_user.cards.new(board: @board)

    if @board.save && card.save
      redirect_to @board, notice: 'Board was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /boards/1
  def update
    unless @board.leader == current_user
      flash[:alert] = 'リーダー以外は編集できません'
      redirect_to boards_path
      return
    end
    if @board.update(board_params)
      redirect_to @board, notice: 'Board was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /boards/1
  def destroy
    unless @board.leader == current_user
      flash[:alert] = 'リーダー以外は削除できません'
      redirect_to boards_path
      return
    end
    @board.destroy
    redirect_to boards_url, notice: 'Board was successfully destroyed.'
  end

  # POST /boards/1/join
  def join
    unless @board.wait?
      flash[:alert] = 'ゲーム中のため入れません'
      redirect_to boards_path
      return
    end
    keyword = params[:keyword]
    unless @board.cards.find_by(user_id: current_user.id)
      current_user.cards.create(board: @board)
    end
    if keyword == @board.keyword
      flash[:notice] = 'joinしたお'
      redirect_to board_path(@board)
    else
      flash[:alert] = 'キーワードが間違ってるよ'
      redirect_to boards_path
    end

    BoardBroadcastJob.perform_later(@board.id, { type: 'join', user: current_user.id })
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board = Board.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def board_params
    params.require(:board).permit(:name, :keyword)
  end
end
