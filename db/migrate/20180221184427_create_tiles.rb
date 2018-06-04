class CreateTiles < ActiveRecord::Migration[5.1]
  def change
    create_table :tiles do |t|
      t.belongs_to :game, foreign_key: true
      t.string :name
      t.string :status
      t.integer :position
      t.string :treasure

      t.timestamps
    end
  end
end
