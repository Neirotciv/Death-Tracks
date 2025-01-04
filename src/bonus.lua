local map = require("map")

bonusList = {}
local bonusMax = game.maxBonus

local bonus = {}
  bonus.size = 16
  bonus.scale = 2
  bonus.scaleSize = bonus.size * bonus.scale 
  bonus.time = 0

  bonus.booster = {}
    bonus.booster.time = 3
    bonus.booster.image = nil
    
  bonus.mine = {}
    bonus.mine.image = nil
    bonus.mine.damage = 5
    bonus.mine.reduceSpeed = 20
    bonus.booster.time = 2

  bonus.ammoBox = {}
    bonus.ammoBox.image = assetManager:getImage("ammo")
    bonus.ammoBox.total = 2
    
  bonus.dollar = {}
    bonus.dollar.image = assetManager:getImage("money")
    
  bonus.repair = {}
    bonus.repair.image = assetManager:getImage("repair")
    
  bonus.tile = 0
  
function bonus:new(pLine, pColumn, pCategory, pValue)
  -- Centrage dans la tile
  local newBonus = {}
    newBonus.x = (map.tileSize - 32) / 2 + ((pColumn-1) * map.tileSize) * map.scale
    newBonus.y = (map.tileSize - 32) / 2 + ((pLine-1) * map.tileSize-1) * map.scale
    newBonus.xo = newBonus.x + bonus.scaleSize / 2
    newBonus.yo = newBonus.y + bonus.scaleSize / 2
    newBonus.category = pCategory
    newBonus.value = pValue
    
  table.insert(bonusList, newBonus)
end

function bonus:remove(pId)
  for i=#bonusList, 1, -1 do
    if i == pId then
      table.remove(bonusList, pId)
    end
  end
end

function bonus:update(dt)
  -- Temps aléatoire pour l'apparition d'un bonus
  bonus.time = math.random(5, 10)
  
  if #bonusList < bonusMax then
    local id = math.random(1, #map.driveMap)
    local line = map.driveMap[id].line 
    local column = map.driveMap[id].column
    
    local rand = math.random(1, 3)
    if rand == 1 then
      bonus:new(line, column, "ammo", 5)
    elseif rand == 2 then
      bonus:new(line, column, "dollar", 10)
    elseif rand == 3 then
      bonus:new(line, column, "repair", 20)
    end
  end
  
  -- Collision entre un tank et un bonus + ajout dans l'inventaire
  for i=1, #ia_list do
    local tank = ia_list[i]
    for j=#bonusList, 1, -1 do
      local b = bonusList[j]
      if tank.x > b.x and tank.x < b.x + bonus.scaleSize and tank.y > b.y and tank.y < b.y + bonus.scaleSize then
        tank:addBonus(b.category, b.value)
        bonus:remove(j)
      end
    end
  end
end

function bonus:draw()
  for i=1, #bonusList do
    if bonusList[i].category == "ammo" then
      love.graphics.draw(bonus.ammoBox.image, bonusList[i].x, bonusList[i].y, 0, bonus.scale, bonus.scale)
    end
    if bonusList[i].category == "dollar" then
      love.graphics.draw(bonus.dollar.image, bonusList[i].x, bonusList[i].y, 0, bonus.scale, bonus.scale)
    end
    if bonusList[i].category == "repair" then
      love.graphics.draw(bonus.repair.image, bonusList[i].x, bonusList[i].y, 0, bonus.scale, bonus.scale)
    end
    
    --Hitbox du bonus
    --love.graphics.rectangle("line", bonusList[i].x, bonusList[i].y, self.scaleSize, self.scaleSize)
  end
  
end

return bonus
