local game = {}

camera = {}
  camera.x = 0
  camera.y = 0
  
windows = {}
  windows.width = love.graphics.getWidth()
  windows.height = love.graphics.getHeight()

font = love.graphics.newFont(30)
font_low = love.graphics.newFont(20)
font_veryLow = love.graphics.newFont(10)

game.maxBonus = 5

game.money = 10000
game.life = 49

game.lvl_shield = 1
game.lvl_speed = 1
game.lvl_damage = 1

-- Prix des améliorations au début du jeu
game.price_shield = 1000
game.price_speed = 200
game.price_repair = 0
game.price_damage = 10

game.state = "MENU" -- MENU, PLAY ou PAUSE
game.menu_state = "MAIN_MENU" -- MAIN_MENU, RACE_MENU, UPGRADE_MENU

game.race_state = "START" -- START, IN_PROGRESS ou END


return game