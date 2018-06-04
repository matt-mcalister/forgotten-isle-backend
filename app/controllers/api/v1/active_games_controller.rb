class Api::V1::ActiveGamesController < ApplicationController

  def create
    @active_game = ActiveGame.find_or_initialize_by(game_id: params[:game_id], user_id: params[:user_id])
    if @active_game.valid?
      @active_game.save
      @game = Game.find(params[:game_id])
      serialized_active_game = ActiveModelSerializers::Adapter::Json.new(
        ActiveGameSerializer.new(@active_game)
      ).serializable_hash

      ActiveGamesChannel.broadcast_to @game, serialized_active_game
      head :ok

    end
  end

  def update
    active_game = ActiveGame.find_by(id: params[:id])

    active_game.update(active_game_params)

    game = active_game.game

    if !active_game_params.keys.include?("ready_to_start")
      if params[:shoring]
        shored_tile = Tile.find_by(game_id: active_game.game_id, position: params[:shoring])
        shored_tile.update(status: "dry")
      elsif params[:get_treasure]
        active_game.trade_treasure_cards(params[:get_treasure])
      elsif params[:gift_treasure]
        active_game.give_treasure_card(params[:gift_treasure], params[:gift_to])
      elsif params[:card_to_discard]
        active_game.discard(params[:card_to_discard])
      elsif params[:sandbag]
        active_game.sandbag(Tile.find(params[:sandbag]))
      elsif params[:lift_destination]
        active_game.helicopter_lift(params[:players_to_lift], params[:lift_destination])
      elsif params[:navigating_id]
        ActiveGame.find(params[:navigating_id]).update(position: params[:navigating_position])
      end




      if active_game.is_users_turn? && active_game.actions_remaining == 0
        game.next_users_turn
      end

      active_game = ActiveGame.find_by(id: params[:id])
      active_game.game.game_over?

      game = Game.find(active_game.game_id)

      serialized_game = ActiveModelSerializers::Adapter::Json.new(
        GameSerializer.new(game)
      ).serializable_hash

      serialized_active_games = game.active_games.map do |ag|
        ActiveModelSerializers::Adapter::Json.new(
          ActiveGameSerializer.new(ag)
          ).serializable_hash
      end

      if params[:navigating_id]
        serialized_active_games.find {|ag| ag[:active_game][:id] == params[:navigating_id]}[:active_game][:must_relocate?] = false
        serialized_game[:game][:halt_game?] = false
      end

      serialized_tiles = game.tiles.map do |tile|
        ActiveModelSerializers::Adapter::Json.new(
          TileSerializer.new(tile)
          ).serializable_hash
      end

      serialized_messages = game.messages.map do |message|
        ActiveModelSerializers::Adapter::Json.new(
          MessageSerializer.new(message)
          ).serializable_hash
      end


      ActiveGamesChannel.broadcast_to game, {new_turn: {game: serialized_game, active_games: serialized_active_games, tiles: serialized_tiles, messages: serialized_messages}}
      head :ok

    else

      serialized_active_game = ActiveModelSerializers::Adapter::Json.new(
        ActiveGameSerializer.new(active_game)
      ).serializable_hash

      ActiveGamesChannel.broadcast_to game, serialized_active_game
      head :ok
    end

  end

  def destroy
    active_game = ActiveGame.find(params[:id])
    if active_game
      active_game.exit_game
      serialized_active_game = ActiveModelSerializers::Adapter::Json.new(
        ActiveGameSerializer.new(active_game)
      ).serializable_hash
      game_id = active_game.game_id
      active_game.destroy

      game = Game.find(game_id)

      serialized_game = ActiveModelSerializers::Adapter::Json.new(
        GameSerializer.new(game)
      ).serializable_hash

      serialized_active_games = game.active_games.map do |ag|
        ActiveModelSerializers::Adapter::Json.new(
          ActiveGameSerializer.new(ag)
          ).serializable_hash
      end
      data = {removed_active_game: serialized_active_game[:active_game], game: serialized_game, active_games: serialized_active_games }
      ActiveGamesChannel.broadcast_to(game, data)
      head :ok
    else
      render json: {message: "ActiveGame has already been destroyed"}
      head :ok
    end
  end

  private
    def active_game_params
      params.require(:active_game).permit(:id, :game_id, :user_id, :ready_to_start, :position, :treasure_cards, :actions_remaining, :turn_action, :navigations_remaining)
    end

end
