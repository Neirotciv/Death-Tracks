io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest") -- Pixel art
if arg[#arg] == "-debug" then require("mobdebug").start() end

assetManager  = require("assetManager")
tank          = require("tank")
map           = require("map")
ia            = require("ia")
game          = require("game")
camera        = require("camera")
ui_tank       = require("ui/ui_tank")
ui_menu       = require("ui/ui_menu")
ui_race       = require("ui/ui_race")
bonus         = require("bonus")
time          = require("time")

ia_list = {}
local debugMode = false

function love.load()
  love.window.setMode(800, 600)
  w = love.graphics.getWidth()
  h = love.graphics.getHeight()
  
  assetManager:loadAssets()

  bonus:load()
  map.load()
  
  player = tank.newTank(350, 100, 1)
  ia_list[1] = player
  ia_list[2] = ia.new(350, 150, 2)
  ia_list[3] = ia.new(300, 100, 3)
  ia_list[4] = ia.new(300, 150, 4)
  
  ia_list[1]:init()
  ia_list[2]:init()
  ia_list[3]:init()
  ia_list[4]:init()
  
  ui_tank:loadInfos(player)
  ui_menu:init()
  ui_race:init()
  
  map.selectRace(1)
end

function love.update(dt)
  if game.state == "MENU" then
    ui_menu:update(dt)
    
  elseif game.state == "PLAY" then
    ui_race:update(dt)
    time:update(dt)
    map.update(dt)
    player:update(dt)
    -- Tanks
    
    ia_list[2]:update(dt)
    ia_list[3]:update(dt)
    ia_list[4]:update(dt)
  
    -- Update de la création et l'acquisition des bonus
    bonus:update(dt)
    -- Compte à rebours
  
    ui_tank:updateInfos(player)
  end
end

function love.draw()
  if game.state == "MENU" then
    ui_menu:draw()
  elseif game.state == "PLAY" then
    camera:set()
      map.draw()
      player:drawTrails()
      ia_list[2]:drawTrails()
      ia_list[3]:drawTrails()
      ia_list[4]:drawTrails()
      
      bonus:draw()
      player:draw()
      ia_list[2]:draw()
      ia_list[3]:draw()
      ia_list[4]:draw()
    camera:unset()
    -- Compte à rebours
    ui_race:draw()
    player:drawDebug()
  end
  
  -- Affichage des UIs en dehors de la caméra
  if game.state == "PLAY" then
    love.graphics.setColor(1, 1, 1)
    ui_tank:drawInfo()
    time:draw()
    love.graphics.print("fps "..love.timer.getFPS(), w - 50, 5)
    --player:drawDebug()
  end
  
  love.graphics.setFont(font_veryLow)
  love.graphics.print("game state : "..tostring(game.state).."\t menu state : "..tostring(game.menu_state).."\t race state : "..tostring(game.race_state), 5, h-15)
end

function love.keypressed(key)
  if key == "2" then
    ia_list[2]:moveForward()
  end
  if key == "3" then
    ia_list[3]:moveForward()
  end
  if key == "4" then
    ia_list[4]:moveForward()
  end
  if key == "1" then
    ia_list[2]:moveForward()
    ia_list[3]:moveForward()
    ia_list[4]:moveForward()
  end
  
  if key == "c" then
    camera:setScale()
  end
  
  -- Retour au menu avec la touche echap
  if game.state == "PLAY" and key == "escape" then
    game.state = "MENU"
  end

  if key == "b" then
    debugMode = not debugMode
    player:setDebug(debugMode)
  end
end

function love.mousepressed(x, y, btn)
  if game.state == "PLAY" then
    player:mousepressed(x, y, btn)
  end
end