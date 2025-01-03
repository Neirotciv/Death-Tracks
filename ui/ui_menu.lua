local ui               = require("ui/ui")
local ui_upgrade       = require("ui/ui_upgrade")
local ui_selectRace    = require("ui/ui_selectRace")

local ui_menu = {}
local currentMenu = "MAIN_MENU"
local pause = false

local function quit() love.event.quit(true) end
local function newRace() game.menu_state = "RACE_MENU" ui_upgrade:init() newGame = true end

function ui_menu:init()
  self.frame_mainMenu = ui.newFrame(0, 0, w, h)
    self.frame_mainMenu:setBackgroundColor(27, 38, 50, 255)
  
  self.btn_newRace = ui.newButton(w/2-100, h/2-95, 200, 50, "NEW RACE", font)
    self.btn_newRace:setEvent("pressed", newRace)
  self.btn_options = ui.newButton(w/2-100, self.btn_newRace.y + 70, 200, 50, "OPTIONS", font)
  self.btn_quit = ui.newButton(w/2-100, self.btn_options.y + 70, 200, 50, "QUIT", font)
    self.btn_quit:setEvent("pressed", quit)
    
  -- Si le joueur ouvre le menu pendant la course, remplacer New Race par Continue
  self.btn_continue = ui.newButton(w/2-100, h/2-95, 200, 50, "CONTINUE", font)
  
  self.frame_mainMenu:addElement(w/2-100, h/2-95, self.btn_newRace)
  --self.frame_mainMenu:addElement(w/2-100, h/2-95, self.btn_continue)
  --self.frame_mainMenu:addElement(w/2-100, self.btn_newRace.y + 70, self.btn_options)
  self.frame_mainMenu:addElement(w/2-100, self.btn_options.y + 70, self.btn_quit)
    
  self.frame_optionsMenu = ui.newFrame(0, 0, w, h)
    self.frame_optionsMenu:setBackgroundColor(27, 38, 50, 255)
    
  self.frame_raceMenu = ui.newFrame(0, 0, w, h)
    self.frame_raceMenu:setBackgroundColor(27, 38, 50, 255)
    
  self.frame_upgradeMenu = ui.newFrame(0, 0, w, h)
    self.frame_upgradeMenu:setBackgroundColor(27, 38, 50, 255)
    
  ui_selectRace:init()
  ui_upgrade:init()
end

function ui_menu:update(dt)
  -- FAIRE LA DISTINCTION ENTRE NOUVELLE PARTIE ET PARTIE EN COURS /|\
  currentMenu = game.menu_state
  if currentMenu == "MAIN_MENU" then
    self.frame_mainMenu:update(dt)
  elseif currentMenu == "RACE_MENU" then
    if game.race_state == "END" then
      -- Les conditions de fin de course sont remis à 0 pour chaque joueur
      for i=1, #ia_list do
        ia_list[i]:reloadRaceInfos()
      end
    end
    ui_selectRace:update(dt)
  elseif currentMenu == "UPGRADE_MENU" then
    ui_upgrade:update(dt)
  end
end

function ui_menu:draw()
  if currentMenu == "MAIN_MENU" then
    self.frame_mainMenu:draw()
  elseif currentMenu == "OPTIONS_MENU" then
    self.frame_optionsMenu:draw()
  elseif currentMenu == "RACE_MENU" then
    self.frame_raceMenu:draw()
    ui_selectRace:draw()
  elseif currentMenu == "UPGRADE_MENU" then
    self.frame_upgradeMenu:draw()
    ui_upgrade:draw()
  end
end

return ui_menu