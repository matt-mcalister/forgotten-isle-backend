class GameSerializer < ActiveModel::Serializer
  attributes :id, :name, :water_level, :end_game, :flood_cards, :flood_discards, :treasure_cards, :treasure_discards, :current_turn_id, :in_session, :treasures_obtained, :halt_game?
  has_many :tiles
  has_many :active_games
  has_many :users, through: :active_games
  has_many :messages, through: :active_games
end
