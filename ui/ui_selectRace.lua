local ui   = require("ui/ui")
local game = require("game")
local map  = require("map")

local ui_selectRace = {}

local function backButton() game.menu_state = "MAIN_MENU" game.state = "MENU" end
local function upgradeButton() game.menu_state = "UPGRADE_MENU" game.state = "MENU" end
local function level1() map.selectRace(1) ui_selectRace:reloadInfos() end
local function level2() map.selectRace(2) ui_selectRace:reloadInfos() end
local function level3() map.selectRace(3) ui_selectRace:reloadInfos() end
local function level4() map.selectRace(4) ui_selectRace:reloadInfos() end
local function level5() map.selectRace(5) ui_selectRace:reloadInfos() end

function ui_selectRace:init()
  self.state = "RACE_MENU"
  game.race_state = "PLAY"
  
  self.title = ui.newLabel(w/2, 30, 0, 0, "SELECT RACE", font, "center", "center")
  self.btn_back = ui.newButton(10, 10, 100, 40, "BACK", font_low)
    self.btn_back:setEvent("pressed", backButton)
  self.btn_upgrade = ui.newButton(w-110, 10, 100, 40, "GARAGE", font_low)
    self.btn_upgrade:setEvent("pressed", upgradeButton)
    
  -- Frame d'infos du niveau
  self.frame_infos = ui.newFrame(10, 100, 150, 100)
    self.frame_infos:setBackgroundColor(0, 0, 0, 0)
    self.frame_infos:setOutlineColor(0, 0, 0, 0)
    self.lbl_laps = ui.newLabel(0, 0, 100, 20, "Laps : "..map.level.maxLaps, font_low, "left", "center")
    self.lbl_price = ui.newLabel(0, 0, 100, 20, "Price : "..map.level.price, font_low, "left", "center")
  self.frame_infos:addElement(0, 10, self.lbl_laps)
  self.frame_infos:addElement(0, 40, self.lbl_price)
  
  if map.level.lock == true then
    self.lbl_lock = ui.newLabel(w/2, 130+(20 * (map.tileSize / 5)), 0, 20, "Lock", font, "center", "center")
  else
    self.lbl_lock = ui.newLabel(w/2, 120+(20 * (map.tileSize / 5)), 0, 20, "Unlock", font, "center", "center")
  end
    
  -- Boutons du choix des niveaux
  self.frame_levels = ui.newFrame(0, h-120, w, 120)
    self.frame_levels:setBackgroundColor(0.18, 0.28, 0.3)
  self.btn_lvl1 = ui.newButton(0, 0, 40, 40, "1", font_low)
    self.btn_lvl1:setBackgroundColor(0.3, 0.49, 0.49)
    
    self.btn_lvl1:setEvent("pressed", level1)
  self.btn_lvl2 = ui.newButton(0, 0, 40, 40, "2", font_low)
    self.btn_lvl2:setBackgroundColor(0.3, 0.49, 0.49)
    self.btn_lvl2:setEvent("pressed", level2)
  self.btn_lvl3 = ui.newButton(0, 0, 40, 40, "3", font_low)
    self.btn_lvl3:setBackgroundColor(0.3, 0.49, 0.49)
    self.btn_lvl3:setEvent("pressed", level3)
  self.btn_lvl4 = ui.newButton(0, 0, 40, 40, "4", font_low)
    self.btn_lvl4:setBackgroundColor(0.3, 0.49, 0.49)
    self.btn_lvl4:setEvent("pressed", level4)
  self.btn_lvl5 = ui.newButton(0, 0, 40, 40, "5", font_low)
    self.btn_lvl5:setBackgroundColor(0.3, 0.49, 0.49)
    self.btn_lvl5:setEvent("pressed", level5)
    
  self.frame_levels:addElement(10, 10, self.btn_lvl1)
  self.frame_levels:addElement(60, 10, self.btn_lvl2)
  self.frame_levels:addElement(110, 10, self.btn_lvl3)
  self.frame_levels:addElement(160, 10, self.btn_lvl4)
  self.frame_levels:addElement(210, 10, self.btn_lvl5)
end

function ui_selectRace:reloadInfos()
  self.lbl_laps.text = "Laps : "..map.level.maxLaps
  self.lbl_price.text = "Price : "..map.level.price
  if map.level.lock == true then
    self.lbl_lock.text = "Lock"
    self.lbl_lock:reload()
  else
    self.lbl_lock.text = "Unlock"
    self.lbl_lock:reload()
  end
  
  ia_list[1]:reloadBeforeRace()
  ia_list[2]:reloadBeforeRace()
  ia_list[3]:reloadBeforeRace()
  ia_list[4]:reloadBeforeRace()
end

function ui_selectRace:update(dt)
  self.btn_back:update(dt)
  if map.level.lock then 
    self.btn_upgrade:setBackgroundColor(0.39, 0.19, 0.19)
  else 
    self.btn_upgrade:setBackgroundColor(0.39, 0.39, 0.39)
    self.btn_upgrade:update(dt) 
  end
  self.frame_levels:update(dt)
end

function ui_selectRace:draw()
  self.title:draw()
  self.btn_back:draw()
  self.btn_upgrade:draw()
  
  self.frame_levels:draw()
  self.frame_infos:draw()
  self.lbl_lock:draw()
  
  -- Affichage de la miniature de la map
  map.drawMin(w/2, 100)
end

return ui_selectRace