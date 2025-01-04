local ui = require("ui/ui")

local ui_tank = {}
  ui_tank.x = 0
  ui_tank.y = 0
  ui_tank.speed = 0
  ui_tank.life = 0
  ui_tank.bonus = "NIL"
  ui_tank.ammo = 0
  ui_tank.currentWeapon = 0
  ui_tank.currentIcon = nil
  ui_tank.lap = 0

function ui_tank:loadInfos(pPlayer)
  ui_tank.speed = math.floor(pPlayer.speed)
  ui_tank.life = pPlayer.life 
  ui_tank.bonus = pPlayer.bonus
  ui_tank.ammo = pPlayer.ammo
  ui_tank.currentWeapon = pPlayer.currentWeapon
  ui_tank.money = pPlayer.money
  ui_tank.width = w
  ui_tank.height = 30
  ui_tank.lap = pPlayer.lap
  
  ui_tank.icon_bullet = ui.newIcon(450, 5, "assets/img/bullet_icon.png", 2)
  ui_tank.icon_bomb = ui.newIcon(450, 5, "assets/img/bomb_icon.png", 2)
end

function ui_tank:updateInfos(pPlayer)
  ui_tank.speed = math.floor(pPlayer.speed)
  ui_tank.life = pPlayer.life 
  ui_tank.bonus = pPlayer.bonus
  ui_tank.ammo = pPlayer.ammo
  ui_tank.currentWeapon = pPlayer.currentWeapon
  ui_tank.money = pPlayer.money
  ui_tank.width = w
  ui_tank.height = 60
  ui_tank.lap = pPlayer.lap
  
  if self.currentWeapon == 1 then
    self.currentIcon = self.icon_bullet
  elseif self.currentWeapon == 2 then
    self.currentIcon = self.icon_bomb
  end
end

function ui_tank:drawInfo()
  love.graphics.setColor(0.39, 0.39, 0.39)
  love.graphics.rectangle("fill", ui_tank.x, ui_tank.y, ui_tank.width, ui_tank.height)
  love.graphics.setColor(0.04, 0.04, 0.04)
  love.graphics.print("speed : "..ui_tank.speed, ui_tank.x + 10, ui_tank.y + 5)
  love.graphics.print("life : "..ui_tank.life, ui_tank.x + 100, ui_tank.y + 5)
  love.graphics.print("ammo : "..ui_tank.ammo, ui_tank.x + 190, ui_tank.y + 5)
  love.graphics.print("weapon : "..ui_tank.currentWeapon, ui_tank.x + 280, ui_tank.y + 5)
  love.graphics.print("wallet : "..ui_tank.money, ui_tank.x + 370, ui_tank.y + 5)
  love.graphics.print("laps : "..ui_tank.lap.." / "..map.level.maxLaps, ui_tank.x + 460, ui_tank.y + 5)
  love.graphics.setColor(1, 1, 1)
  
  -- Icône du bonus
  --self.currentIcon:draw()
end

return ui_tank