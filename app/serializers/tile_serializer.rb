class TileSerializer < ActiveModel::Serializer
  attributes :id, :name, :status, :position, :treasure
  belongs_to :game
end
