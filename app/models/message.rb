class Message < ApplicationRecord
  belongs_to :active_game
  has_one :user, through: :active_game
end
