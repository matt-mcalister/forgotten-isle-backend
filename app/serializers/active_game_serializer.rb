class ActiveGameSerializer < ActiveModel::Serializer
  attributes :id, :position, :ability, :treasure_cards, :ready_to_start, :is_users_turn?, :actions_remaining, :can_get_treasure?, :can_trade_cards_with_user?, :must_discard?, :must_relocate?, :can_fly, :navigations_remaining
  belongs_to :user
  belongs_to :game
  has_many :messages
end
