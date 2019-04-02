
Message.destroy_all
ActiveGame.destroy_all
Tile.destroy_all
Game.destroy_all
User.destroy_all

Game.create(name: "Beginners only!", water_level: 1)
Game.create(name: "Explorers Unite", water_level: 2)
Game.create(name: "Let's do this", water_level: 3)
Game.create(name: "Indiana Jones 4 life", water_level: 4)
