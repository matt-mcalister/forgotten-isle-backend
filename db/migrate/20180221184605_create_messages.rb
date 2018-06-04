class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.belongs_to :active_game, foreign_key: true
      t.string :text
      t.string :alert

      t.timestamps
    end
  end
end
