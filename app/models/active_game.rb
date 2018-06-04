class ActiveGame < ApplicationRecord
  belongs_to :user
  belongs_to :game
  has_many :messages, dependent: :destroy

  after_create :assign_ability

  def exit_game
    if self.treasure_cards
      self.treasure_cards.each do |card|
        self.game.add_to_treasure_discards(card)
      end
    end
    if self.game.current_turn_id == self.id && self.game.active_games.length > 1
      current_turn_index = self.game.turn_order.map {|ag| ag.id}.index(self.game.current_turn_id)

      if current_turn_index == self.game.active_games.length - 1
        current_turn_index = -1
      end
      current_turn_id = self.game.turn_order[current_turn_index+1].id
      self.game.update(current_turn_id: current_turn_id)
      ActiveGame.find(current_turn_id).update(actions_remaining: 3)
    end
  end

  def sandbag(tile)
    tile.update(status: "dry")
    self.discard("Sandbag")
  end

  def helicopter_lift(active_games, destination_tile_position)
    active_games.each do |ag|
      ActiveGame.find(ag["id"]).update(position: destination_tile_position)
    end
    self.discard("Helicopter Lift")
  end

  def must_relocate?
    if (self.is_users_turn? && self.ability == "Diver")
      false
    else
      self.position && self.game_id && Tile.find_by(game_id: self.game_id, position: self.position).status == "abyss"
    end
  end

  def can_relocate?
    self.can_move_up? || self.can_move_down? || self.can_move_left? || self.can_move_right?
  end

  def can_move_up?
    case self.position
    when 23..24, 19..22, 13..18, 8..11, 4..5
      true
    else
      false
    end
  end

  def can_move_down?
    case self.position
    when 1..2, 3..6, 7..12, 14..17, 20..21
      true
    else
      false
    end
  end

  def can_move_right?
    case self.position
    when 7, 13, 3, 8, 14, 19, 1, 4, 9, 15, 20, 23, 5, 10, 16, 21, 11, 17
      true
    else
      false
    end
  end

  def can_move_left?
    case self.position
    when 12, 18, 6, 11, 17, 22, 2, 5, 10, 16, 21, 24, 4, 9, 15, 20, 8, 14
      true
    else
      false
    end
  end

  def must_discard?
    self.treasure_cards ||= []
    self.treasure_cards.length > 5
  end

  def discard(card)
    newTreasureCards = self.treasure_cards
    newTreasureCards.delete_at(newTreasureCards.index(card))

    self.update(treasure_cards: newTreasureCards)
    self.game.add_to_treasure_discards(card)
  end


  def trade_treasure_cards(treasure)
    startingTreasureCardsLength = self.treasure_cards.length
    newTreasureCards = self.treasure_cards.reject {|treasure_card| treasure_card == treasure}
    self.update(treasure_cards: newTreasureCards)
    (startingTreasureCardsLength - newTreasureCards.length).times do
      self.game.add_to_treasure_discards(treasure)
    end

    arr = self.game.treasures_obtained || []
    arr << treasure
    self.game.update(treasures_obtained: arr)

    tiles = Tile.where(game_id: self.game.id, treasure: treasure)

    tiles.each do |tile|
      tile.update(treasure: nil)
    end
  end

  def can_fly
    self.ability == "Pilot" && self.turn_action && self.is_users_turn?
  end

  def give_treasure_card(treasure_card, active_game_id)
    self.treasure_cards.delete_at(self.treasure_cards.index(treasure_card))
    self.update(treasure_cards: self.treasure_cards)
    active_game = ActiveGame.find(active_game_id)
    new_treasure_cards = [active_game.treasure_cards, treasure_card].flatten
    active_game.update(treasure_cards: new_treasure_cards )
  end

  def can_trade_cards_with_user?
    self.ability == "Messenger" || self.game.active_games.any? {|ag| ag.id != self.id && ag.position == self.position}
  end

  def is_users_turn?
    self.id === self.game.current_turn_id
  end

  def can_get_treasure?
    if self.treasure_cards && self.treasure_cards.length > 3
      counter = self.treasure_cards.each_with_object(Hash.new(0)) { |treasure,counter| counter[treasure] += 1 }
      treasure = counter.find {|treasure_card, count| count >= 4}
      if !treasure
        false
      else
        treasure.first
      end
    else
      false
    end
  end

  def assign_ability
    abilities = [
      "Pilot",
      "Navigator",
      "Explorer",
      "Diver",
      "Engineer",
      "Messenger"
    ].select {|ability_name| !self.game.active_games.map {|active_game| active_game.ability}.include?(ability_name) }
    if abilities.length > 1
      self.ability = abilities.sample
      if self.save
        self.assign_position
      else
        byebug
      end
    else
      byebug
    end
  end

  def assign_position
    positions = {
      "Pilot": "Fools Landing",
      "Diver": "Iron Gate",
      "Explorer": "Copper Gate",
      "Engineer": "Cobalt Gate",
      "Messenger": "Silver Gate",
      "Navigator": "Gold Gate"
    }
    starting_tile = self.game.tiles.find {|tile| tile.name == positions[self.ability.to_sym]}
    if starting_tile
      self.position = starting_tile.position
      self.save
    elsif positions.keys.include?(self.ability)
      self.assign_position
    else
      self.assign_ability
    end
  end
end
