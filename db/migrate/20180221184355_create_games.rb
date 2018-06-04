class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :name
      t.integer :water_level
      t.string :flood_cards, array: true
      t.string :flood_discards, array: true
      t.string :treasure_cards, array: true
      t.string :treasure_discards, array: true
      t.boolean :in_session, default: false
      t.integer :current_turn_id
      t.string :treasures_obtained, array: true
      t.string :end_game


      t.timestamps
    end
  end
end
