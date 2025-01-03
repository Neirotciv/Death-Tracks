local time = require("time")
local map  = require("map")

local ui_race = {}

-- Affichage du compte à rebours.
function ui_race:init()
  self.currentImage = 3
  self.countdownImage = {}
    self.countdownImage[1] = love.graphics.newImage("img/ui/countdown_1.png")
    self.countdownImage[2] = love.graphics.newImage("img/ui/countdown_2.png")
    self.countdownImage[3] = love.graphics.newImage("img/ui/countdown_3.png")
  self.countdown = 3
  self.countdownEnd = false
end

function ui_race:update(dt)
  self.countdown = self.countdown - dt
  if self.countdown <= 2 then
    self.currentImage = 2
  end
  if self.countdown <= 1 then
    self.currentImage = 1
  end
  if self.countdown <= 0 then
    self.countdown = 0
    self.countdownEnd = true
    game.race_state = "IN_PROGRESS"
    time:startChrono()
  end
  for i=1, #ia_list do
    local player = ia_list[1].finish
    local ia2 = ia_list[2].finish
    local ia3 = ia_list[3].finish
    local ia4 = ia_list[4].finish
    
    local destroy1 = ia_list[1].destroy
    local destroy2 = ia_list[2].destroy
    local destroy3 = ia_list[3].destroy
    local destroy4 = ia_list[4].destroy
    
    if player or destroy1 and ia2 or destroy2 and ia3 or destroy3 and ia4 or destroy4 then
      game.race_state = "END"
      game.state = "MENU"
      if map.levels[map.currentLevel].finish == false then
        map.levels[map.currentLevel].finish = true 
      end
    end
  end
end

function ui_race:draw()
  -- Compte à rebours
  if self.countdownEnd == false then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.countdownImage[self.currentImage], w/2, h/2, 0, 10, 10, 8, 8)
    love.graphics.print(self.countdown, 10, 10)
  end
  
  -- Fin de la course, affichage des temps
  if game.race_state == "END" then
    
  end
end

return ui_race