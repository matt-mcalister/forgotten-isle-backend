class User < ApplicationRecord
  has_many :active_games
  has_many :games, through: :active_games
  has_many :messages, through: :active_games
end
