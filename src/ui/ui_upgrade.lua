local ui_upgrade = {}
local ui   = require("ui/ui")
local ui_race  = require("ui/ui_race")
local game = require("game")

local tankScale = 6

local function addShieldPoint() 
  game.lvl_shield = game.lvl_shield + 1
  game.money = game.money - game.price_shield
end
local function 
  addSpeedPoint() game.lvl_speed = game.lvl_speed + 1
  game.money = game.money - game.price_speed
end
local function addDamagePoint() 
  game.lvl_damage = game.lvl_damage + 1 
  game.money = game.money - game.price_damage 
end

local function backButton() game.menu_state = "RACE_MENU" game.state = "MENU" end
local function startButton() game.state = "PLAY" game.menu_state = "MAIN_MENU" ui_race:init() end

function ui_upgrade:init()
  self.state = "UPGRADE_MENU"
  self.title = ui.newLabel(screenWidth/2, 30, 0, 0, "UPGRADE", font, "center", "center")
  self.btn_back = ui.newButton(10, 10, 100, 40, "BACK", font_low)
    self.btn_back:setEvent("pressed", backButton)
  self.btn_start = ui.newButton(screenWidth-110, 100, 100, 40, "START", font_low)
    self.btn_start:setEvent("pressed", startButton)
  
    self.img_tank = {}
    self.img_tank.image = love.graphics.newImage("assets/img/tank.png")
    self.img_tank.x = 100
    self.img_tank.y = 100
    self.img_tank.sprite = {}
      self.img_tank.sprite[1] = love.graphics.newQuad(0, 0, 32, 32, self.img_tank.image:getDimensions())
      self.img_tank.sprite[2] = love.graphics.newQuad(32, 0, 32, 32, self.img_tank.image:getDimensions())
      self.img_tank.sprite[3] = love.graphics.newQuad(64, 0, 32, 32, self.img_tank.image:getDimensions())
      self.img_tank.current = 1
  
  self.img_turret = {}
  self.img_turret.image = love.graphics.newImage("assets/img/turret.png")
  self.img_turret.sprite = {}
   self.img_turret.sprite[1] = love.graphics.newQuad(0, 0, 32, 32, self.img_turret.image:getDimensions())
  
  self.upgrade = {}
    self.upgrade[1] = love.graphics.newImage("assets/img/ui/upgrade_1.png")
    self.upgrade[2] = love.graphics.newImage("assets/img/ui/upgrade_2.png")
    self.upgrade[3] = love.graphics.newImage("assets/img/ui/upgrade_3.png")
    self.upgrade[4] = love.graphics.newImage("assets/img/ui/upgrade_4.png")
    self.upgrade[5] = love.graphics.newImage("assets/img/ui/upgrade_5.png")
    self.upgrade[6] = love.graphics.newImage("assets/img/ui/upgrade_6.png")
    self.upgrade[7] = love.graphics.newImage("assets/img/ui/upgrade_7.png")
    
  self.size = (self.img_tank.image:getWidth() * 4) / 2
  self.lbl_shield = ui.newLabel(630, 125, 0, 0, "SHIELD", font, "center", "center")
  self.lbl_speed = ui.newLabel(630, 195, 0, 0, "SPEED", font, "center", "center")
  self.lbl_damage = ui.newLabel(630, 265, 0, 0, "DAMAGE", font, "center", "center")
  
  -- Toolbar
  self.tlbar_upgrade = ui.newToolBar(200, 450, "horizontal")
  self.tlbar_upgrade:setMargin(5, 5, 5, 5, 40)
  self.tlbar_upgrade:setBackgroundColor(0, 0, 0, 0)
  self.tlbar_upgrade:setOutlineColor(0, 0, 0, 0)
    
    self.icn_shield = ui.newIcon(0, 0, "assets/img/ui/shield.png", 5)
      self.icn_shield:setEvent("pressed", addShieldPoint)
    self.icn_speed = ui.newIcon(0, 0, "assets/img/ui/engine.png", 5)
      self.icn_speed:setEvent("pressed", addSpeedPoint)
    self.icn_repair = ui.newIcon(0, 0, "assets/img/ui/repair.png", 5)
    self.icn_damage = ui.newIcon(0, 0, "assets/img/ui/engine.png", 5)
      self.icn_damage:setEvent("pressed", addDamagePoint)
  
  self.tlbar_upgrade:addIcon(self.icn_repair)
  self.tlbar_upgrade:addIcon(self.icn_shield)
  self.tlbar_upgrade:addIcon(self.icn_speed)
  self.tlbar_upgrade:addIcon(self.icn_damage)
  
  -- Prix des améliorations au début du jeu
  self.price_shield = 1000
  self.price_speed = 200
  self.price_damage = 30
  self.price_repair = 0
  
  -- Label d'affichage des prix
  self.lbl_price_repair = ui.newLabel(self.icn_repair.x + (self.icn_repair.width/2), self.icn_repair.y + 100, 0, 0, tostring(game.price_repair).."$", font_low, "center", "center")
  self.lbl_price_shield = ui.newLabel(self.icn_shield.x + (self.icn_shield.width/2), self.icn_shield.y + 100, 0, 0, tostring(game.price_shield).."$", font_low, "center", "center")
  self.lbl_price_speed = ui.newLabel(self.icn_speed.x + (self.icn_speed.width/2), self.icn_shield.y + 100, 0, 0, tostring(game.price_speed).."$", font_low, "center", "center")
  self.lbl_price_damage = ui.newLabel(self.icn_damage.x + (self.icn_damage.width/2), self.icn_damage.y + 100, 0, 0, tostring(game.price_damage).."$", font_low, "center", "center")
  
  -- Barre de vie
  self.lifeBar = {}
    self.lifeBar.x = 100
    self.lifeBar.y = self.img_tank.y + (self.img_tank.image:getHeight() / 2) * tankScale
    self.lifeBar.width = (self.img_tank.image:getWidth() / 4) * tankScale -- Divisé par le nombre de sprite
    self.lifeBar.height = 20
    self.lifeBar.progress = ((self.lifeBar.width * game.life) / 100)
  
  -- Portefeuille
  self.lbl_money = ui.newLabel(screenWidth/2, self.lifeBar.y + 100, 0, 0, "Money : "..tostring(game.money), font, "center", "center")
end

function ui_upgrade:update(dt)
  self.btn_back:update(dt)
  self.btn_start:update(dt)
  
  -- Actualiser le portefeuille
  self.lbl_money.text = game.money
  self.lbl_money:reload()
  
  -- Update de la barre de vie et du prix de réparation
  if game.life < 50 then
    game.price_repair = 100
    self.lbl_price_repair:updateText(tostring(game.price_repair).."$")
  end
  
  if game.money >= game.price_repair then
    self.icn_repair:update(dt)
  end
  
  -- Si on est en dessous du nombre de barre d'amélioration. Sinon bug.
  if game.lvl_shield <= 6 and game.money >= game.price_shield then self.icn_shield:update(dt) end
  if game.lvl_speed <= 6 and game.money >= game.price_speed then self.icn_speed:update(dt) end
  if game.lvl_damage <= 6 and game.money >= game.price_damage then self.icn_damage:update(dt) end
  
  -- Animation du tank
  self.img_tank.current = self.img_tank.current + (6 * dt)
  if math.floor(self.img_tank.current) > #self.img_tank.sprite then
    self.img_tank.current = 1
  end
end

function ui_upgrade:draw()
  self.title:draw()
  self.btn_back:draw()
  self.btn_start:draw()
  
  -- Nom des améliorations
  self.lbl_shield:draw()
  self.lbl_speed:draw()
  self.lbl_damage:draw()
  self.lbl_money:draw()
  
  -- Image du tank et de la bar de vie
  love.graphics.draw(self.img_tank.image, self.img_tank.sprite[math.floor(self.img_tank.current)], self.img_tank.x, self.img_tank.y, 0, tankScale, tankScale)
  love.graphics.draw(self.img_turret.image, self.img_turret.sprite[1], self.img_tank.x, self.img_tank.y, 0, tankScale, tankScale)
  love.graphics.setColor(0.39, 0.71, 0.87)
  love.graphics.rectangle("fill", self.lifeBar.x, self.lifeBar.y, self.lifeBar.progress, self.lifeBar.height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", self.lifeBar.x, self.lifeBar.y, self.lifeBar.width, self.lifeBar.height)
  
  love.graphics.draw(self.upgrade[game.lvl_shield], 400, 100, 0, 3, 3)
  love.graphics.draw(self.upgrade[game.lvl_speed], 400, 170, 0, 3, 3)
  love.graphics.draw(self.upgrade[game.lvl_damage], 400, 240, 0, 3, 3)
  
  -- Toolbar
  self.tlbar_upgrade:draw()
  
  -- Affichage des prix
  self.lbl_price_repair:draw()
  self.lbl_price_shield:draw()
  self.lbl_price_speed:draw()
  self.lbl_price_damage:draw()
end

return ui_upgrade