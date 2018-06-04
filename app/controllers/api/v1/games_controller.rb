class Api::V1::GamesController < ApplicationController

  def index
    games = Game.where(in_session: false)
    render json: games
  end

  def show
    game = Game.find(params[:id])
    active_games = game.active_games

    serialized_game = ActiveModelSerializers::Adapter::Json.new(
      GameSerializer.new(game)
    ).serializable_hash

    serialized_active_games = active_games.map do |ag|
      ActiveModelSerializers::Adapter::Json.new(
        ActiveGameSerializer.new(ag)
        ).serializable_hash
    end

    serialized_messages = game.messages.map do |msg|
      ActiveModelSerializers::Adapter::Json.new(
        MessageSerializer.new(msg)
      ).serializable_hash
    end

    serialized_tiles = game.tiles.map do |tile|
      ActiveModelSerializers::Adapter::Json.new(
        TileSerializer.new(tile)
        ).serializable_hash
    end

    render json: {game: serialized_game, active_games: serialized_active_games, messages: serialized_messages, tiles: serialized_tiles}

  end

  def create
    game = Game.new(game_params)
    if game.valid?
      game.save

      serialized_game = ActiveModelSerializers::Adapter::Json.new(
        GameSerializer.new(game)
      ).serializable_hash

      ActionCable.server.broadcast 'games_channel', serialized_game
      head :ok
    end
  end

  def update
    game = Game.find(params[:id])
    if params[:game][:in_session]
      if game.update(game_params)
        game.initiate_game_session


        serialized_game = ActiveModelSerializers::Adapter::Json.new(
          GameSerializer.new(game)
        ).serializable_hash

        serialized_active_games = game.active_games.map do |ag|
          ActiveModelSerializers::Adapter::Json.new(
            ActiveGameSerializer.new(ag)
            ).serializable_hash
        end

        serialized_tiles = game.tiles.map do |tile|
          ActiveModelSerializers::Adapter::Json.new(
            TileSerializer.new(tile)
            ).serializable_hash
        end

        ActionCable.server.broadcast 'games_channel', {game_in_session: game.id}
        ActiveGamesChannel.broadcast_to game, {game_in_session: {game: serialized_game, active_games: serialized_active_games, tiles: serialized_tiles}}
        head :ok

      end
    else
      if game.update(game_params)

        ActiveGamesChannel.broadcast_to game, {game_in_session: game.id}
        head :ok

      end
    end

  end

  private
    def game_params
      params.require(:game).permit(:id, :name, :water_level, :in_session, :flood_cards, :flood_discards, :treasure_cards, :treasure_discards, :current_turn_id)
    end

end
