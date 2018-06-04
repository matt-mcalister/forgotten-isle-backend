class Api::V1::MessagesController < ApplicationController

  def create
    active_game = ActiveGame.find_by(game_id: params[:game_id], user_id: params[:user_id])
    message = Message.create(active_game_id: active_game.id, text: params[:text])
    game = Game.find(params[:game_id])

    serialized_message = ActiveModelSerializers::Adapter::Json.new(
      MessageSerializer.new(message)
    ).serializable_hash

    ActiveGamesChannel.broadcast_to game, serialized_message
    head :ok

  end

end
