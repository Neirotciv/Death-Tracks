local game = require("game")
local time = require("time")
local tank = {}

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
-- Returns angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

local debug = false
local trailLength = 200

local function addSensor(pX, pY, pDistance, pAngle)
  local sensor = {}
    sensor.angle = pAngle
    sensor.updatedAngle = pAngle
    sensor.distance = pDistance
    sensor.x = pX + pDistance * math.cos(pAngle)
    sensor.y = pY + pDistance * math.sin(pAngle)
    sensor.line = 0
    sensor.column = 0
    sensor.collide = false
  return sensor
end

local function updateSensor(pSensor, pX, pY, pAngle)
    pSensor.updatedAngle = pSensor.angle + pAngle
    pSensor.x = pX + pSensor.distance * math.cos(math.rad(pSensor.updatedAngle))
    pSensor.y = pY + pSensor.distance * math.sin(math.rad(pSensor.updatedAngle))
    pSensor.line = math.floor(((pSensor.y - camera.position.y) - map.cameraY) / (map.tileSize * map.scale)) + 1
    pSensor.column = math.floor(((pSensor.x - camera.position.x) - map.cameraX) / (map.tileSize * map.scale)) + 1
  return pSensor
end

function tank.newTank(pX, pY, pID)
  local tank = {}
  -- Variables du comportement du tank
    tank.id = pID
    tank.x = pX
    tank.y = pY
    tank.cameraX = 0
    tank.cameraY = 0
    tank.vx = 10
    tank.vy = 10
    tank.angle = 0
    tank.size = 32
    tank.state = "STOP"
    tank.type = "PLAYER"
    tank.collide = false
    tank.column = 0
    tank.line = 0
    tank.oldLine = 0
    tank.oldColumn = 0
    tank.sensors = {}
    tank.pathPoints = {}
    
    tank.mouse = { x = 0, y = 0 }
    
    tank.turret = {}
      tank.turret.x = 0
      tank.turret.y = 0
      tank.turret.angle = 0
      tank.turret.state = "NIL"
    
    tank.trailList = {}
    tank.trailImage = love.graphics.newImage("img/trail.png")
    
    tank.bulletList = {}
    tank.bulletImage = love.graphics.newImage("img/bullet.png")
    
    tank.speed = 0
    tank.minSpeed = 50
    tank.maxSpeed = 200
    tank.life = 100
    tank.maxLife = 100
    tank.lap = 0
    tank.bonus = "NIL"
    tank.ammo = 50
    tank.shoot = false
    tank.newLap = false
    tank.finish = false
    tank.halfTurn = false
    tank.scan = false
    tank.destroy = false
    tank.currentWeapon = 1
    tank.timer = 0
    tank.damage = 1
    tank.shield = 1
    tank.money = game.money
    tank.pathTime = 0
    tank.chrono = 0
    tank.mapCopy = {} -- Masquer les tiles déjà parcouru
    
    -- Ajout des capteurs de collision
    -- Eloigné
    tank.sensors = {}
      tank.sensors[1] = addSensor(pX, pY, 128, 0) -- devant
      tank.sensors[2] = addSensor(pX, pY, 128, 315) -- gauche
      tank.sensors[3] = addSensor(pX, pY, 128, 45) -- droite
    
      -- Proche
      tank.sensors[4] = addSensor(pX, pY, 64, 0)
      tank.sensors[5] = addSensor(pX, pY, 64, 330)
      tank.sensors[6] = addSensor(pX, pY, 64, 30)
    
    tank.bonusSensor = addSensor(pX, pY, 100, 0)
    tank.passSensor = addSensor(pX, pY, 64, 0)
  
    -- Images du tank
    tank.img = love.graphics.newImage("img/tank.png")
    tank.sprite = {}
      tank.sprite[1] = love.graphics.newQuad(0, 0, 32, 32, tank.img:getDimensions())
      tank.sprite[2] = love.graphics.newQuad(32, 0, 32, 32, tank.img:getDimensions())
      tank.sprite[3] = love.graphics.newQuad(64, 0, 32, 32, tank.img:getDimensions())
    tank.imgCurrent = 1
    
    -- Image de la tourelle
    tank.turretImg = love.graphics.newImage("img/turret.png")
    tank.turretSpr = love.graphics.newQuad(0, 0, 32, 32, tank.turretImg:getDimensions())
    
  -- A chaque début de course
  function tank:init()
    self.mapCopy = map.level
  end
  
  function tank:reloadRaceInfos()
    tank.lap = 0
    tank.bonus = "NIL"
    tank.newLap = false
    tank.finish = false
  end
  
  -- Remet les variables par défaut
  function tank:reloadBeforeRace()
    self.speed = 0
    self.angle = 0
    self.destroy = false
    self.state = "STOP"
    if self.type == "IA" then
      self.life = self.maxLife
    end
  end
  
  function tank:setPosition(pLine, pColumn)
    self.x = (map.tileSize) / 2 + ((pColumn-1) * map.tileSize) * map.scale
    self.y = (map.tileSize) / 2 + ((pLine-1) * map.tileSize) * map.scale
    self.angle = 0
  end
  
  function tank:update(dt)
    -- Ligne et colonne précédente pour gérer les collisions
    self.oldLine = self.line
    self.oldColumn = self.column
    
    -- Actualisation de la camera
    if self.type == "PLAYER" then
      local deltaX = camera.position.x - (self.x - w / 2)
      local deltaY = camera.position.y - (self.y - (h+60) / 2) -- 60 = hauteur de l'ui_tank pendant la course
      
      -- *0.05 rajoute un effet "smooth"
      camera.position.x = math.floor(camera.position.x - (deltaX * 0.05))
      camera.position.y = math.floor(camera.position.y - (deltaY * 0.05))
      
      -- Réactualisation des coordonnées de la souris par rapport à ceux de la caméra
      self.mouse.x = camera.position.x + love.mouse.getX()
      self.mouse.y = camera.position.y + love.mouse.getY()
      
      -- Angle de la tourelle (suit le curseur de la souris)
      if self.currentWeapon == 1 then
        self.turret.angle = math.angle(self.x, self.y, self.mouse.x, self.mouse.y)
      -- Angle de la mitrailleuse
      elseif self.currentWeapon == 2 then
        self.turret.angle = self.angle
      end
    end
    
    -- Coordonnées du tank après repositionnement de la caméra
    self.cameraX = self.x - camera.position.x
    self.cameraY = self.y - camera.position.y
    
    -- Coordonnées de la tourelle
    tank.turret.x = self.x
    tank.turret.y = self.y
    
    -- Permet d'avancer dans l'axe du tank
    local angle_radian = math.rad(self.angle)
    self.vx = math.cos(angle_radian) * (self.speed * dt)
    self.vy = math.sin(angle_radian) * (self.speed * dt)
    
    -- Scindé en deux pour pouvoir être utilisé par l'ia
    if game.race_state == "IN_PROGRESS" then -- Utilisation du tank après la fin du compte à rebours
      if love.keyboard.isDown("z") and self.type == "PLAYER" and self.finish == false then
        self.state = "MOVE_FORWARD"
      elseif love.keyboard.isDown("s") and self.type == "PLAYER"  then
        self.state = "MOVE_FORBACK"
      elseif self.type == "PLAYER" then
        self.state = "STOP"
      end
      
      if love.keyboard.isDown("q") and self.type == "PLAYER" then
        self.angle = self.angle - 90 * dt
        if self.angle <= 0 then
          self.angle = 360
        end
      end
      if love.keyboard.isDown("d") and self.type == "PLAYER"  then
        self.angle = self.angle + 90 * dt
        if self.angle > 360 then
          self.angle = 1
        end
      end
      
      -- Condition de déplacement avant et arrière
      if self.state == "MOVE_FORWARD" then
        -- Augmentation progressive de la vitesse
        if self.speed <= self.maxSpeed then 
          self.speed = self.speed + 60 * dt
        end
        self.x = tank.x + self.vx
        self.y = tank.y + self.vy
        tank.imgCurrent = tank.imgCurrent + (6 * dt)
        if math.floor(tank.imgCurrent) > #tank.sprite then
          tank.imgCurrent = 1
        end
        self:addTrail()
        self:removeTrail()
        -- **Incrémentation du temps pour tracer les points de passages**
        self.pathTime = self.pathTime + dt
      elseif self.state == "MOVE_FORBACK" then
        self.x = self.x - (self.vx * 0.5)
        self.y = self.y - (self.vy * 0.5)
        self.imgCurrent = tank.imgCurrent - (3 * dt)
        if math.floor(tank.imgCurrent) < 1 then
          self.imgCurrent = 3.9
        end
      elseif self.state == "STOP" then
        self.speed = self.minSpeed
      end
      
      -- Tir au canon
      if self.shoot and self.ammo > 0 then
        self:addBullet()
        self.ammo = self.ammo - 1
        self.shoot = false
      end
      
      -- Actualisation de la position et de l'angle des capteurs
      self.sensors[1] = updateSensor(tank.sensors[1], self.x, self.y, self.angle)
      self.sensors[2] = updateSensor(tank.sensors[2], self.x, self.y, self.angle)
      self.sensors[3] = updateSensor(tank.sensors[3], self.x, self.y, self.angle)
      self.sensors[4] = updateSensor(tank.sensors[4], self.x, self.y, self.angle)
      self.sensors[5] = updateSensor(tank.sensors[5], self.x, self.y, self.angle)
      self.sensors[6] = updateSensor(tank.sensors[6], self.x, self.y, self.angle)
      self.bonusSensor = updateSensor(self.bonusSensor, self.x, self.y, self.angle)
      self.passSensor = updateSensor(self.passSensor, self.x, self.y, self.angle)
      
      -- Collision avec les autres tanks
      for i=1, #ia_list do
        local tankI = ia_list[i]
        for j=1, #ia_list do
          local tankJ = ia_list[j]
          local tankDistance = math.dist(tankI.x, tankI.y, tankJ.x, tankJ.y)
          -- Si la distance est inférieur à la taille d'un tank alors les tanks se repoussent de 2 pixels
          if tankDistance <= self.size then
            if tankI.x > tankJ.x then tankI.x = tankI.x + 2 end
            if tankI.x < tankJ.x then tankI.x = tankI.x - 2 end
            if tankI.y > tankJ.y then tankI.y = tankI.y + 2 end
            if tankI.y < tankJ.y then tankI.y = tankI.y - 2 end
            
            if tankJ.x > tankI.x then tankJ.x = tankJ.x + 2 end
            if tankJ.x < tankI.x then tankJ.x = tankJ.x - 2 end
            if tankJ.y > tankI.y then tankJ.y = tankJ.y + 2 end
            if tankJ.y < tankI.y then tankJ.y = tankJ.y - 2 end
          end
          
          -- IA POUR LE DEPASSEMENT - EN COURS
          if tankI.sensors[4].x >= (tankJ.x - (tankJ.size/2)) and tankI.sensors[4].x <= (tankJ.x + (tankJ.size/2))
          and tankI.sensors[4].y >= (tankJ.y - (tankJ.size/2)) and tankI.sensors[4].y <= (tankJ.y + (tankJ.size/2)) then
            tankI.sensors[4].collide = true
          else
            tankI.sensors[4].collide = false
          end
        end
      end
      
      -- Déplacement des balles
      if #self.bulletList >= 1 then
        for i=#self.bulletList, 1, -1 do
          local bullet = self.bulletList[i]
          local vx = math.cos(bullet.angle) * (450 * dt)
          local vy = math.sin(bullet.angle) * (450* dt)
          bullet.x = bullet.x + vx
          bullet.y = bullet.y + vy
          
          -- Collision des balles avec la map
          local line = math.floor((bullet.y ) / (map.tileSize * map.scale)) + 1
          local column = math.floor((bullet.x ) / (map.tileSize * map.scale)) + 1
          
          if line >= 1 and line <= 20 and column >= 1 and column <= 20 then
            -- Si il n'y a pas de collision
            -- Haut
            if bullet.y - 10 <= (line-1) * map.tileSize and map.level[line-1][column] == 0 then
              bullet.collide = true
              self:removeBullet(i)
            end
            -- Bas
            if bullet.y + 10 >= (line) * map.tileSize and map.level[line+1][column] == 0 then
              bullet.collide = true
              self:removeBullet(i)
            end
            -- Gauche
            if bullet.x - 10 <= (column-1) * map.tileSize and map.level[line][column-1] == 0 then
              bullet.collide = true
              self:removeBullet(i)
            end
            -- Droite
            if bullet.x + 10 >= (column) * map.tileSize and map.level[line][column+1] == 0 then
              bullet.collide = true
              self:removeBullet(i)
            end
            -- Collision des balles avec les tanks
            for j=1, #ia_list do            
              if j == self.id then
                -- Rien
              else
                local tank = ia_list[j]
                local distance = math.dist(bullet.x, bullet.y, tank.x, tank.y)
                if distance <= 16 then 
                --if bullet.x > tank.x - tank.size/2 and bullet.x < tank.x + tank.size/2 and bullet.y > tank.y - tank.size/1 and bullet.y < tank.y + tank.size/2 then
                  bullet.collide = true
                  tank:takeDammage()
                  table.remove(self.bulletList, i)
                end
              end
            end
          else
            -- Si elle sort de la map
            --self:removeBullet(i)
          end
        end
      end
      
      -------------------- IA --------------------
      
      -- Chemin tracé par l'ia pour éviter les demi-tours
      -- Création d'un point toute les 2 secondes
      -- Laisser le temps au tank de démarrer
      if self.pathTime >= 1 and self.halfTurn == false then
        if #self.pathPoints > 1 then
          self.pathPoints[#self.pathPoints-1].area = 32+10
        end
        self:addPathPoint(self.x, self.y)
        self.pathTime = 0
      end
      
      -- Contrôle des points de passage, si le tank est au dessus d'un point créé c'est qu'il a fait demi tour
      --[[for i=#self.pathPoints, 1, -1 do
        local point = self.pathPoints[i]
        if self.x > point.x - point.area and self.x < point.x + point.area and self.y > point.y - point.area and self.y < point.y + point.area then
          self.state = "STOP"
          self.halfTurn = true
        end
      end
      
      if self.halfTurn then
        self.angle = self.angle + 180
        for i=#self.pathPoints, 1, -1 do
          table.remove(self.pathPoints, i)
        end
        self.state = "MOVE_FORWARD"
        self.halfTurn = false
      end]]
      
      -- Masquer les tiles de la mapCopy
      --[[if #self.pathPoints > 1 then
        for i=#self.pathPoints, 2, -1 do
          local point = self.pathPoints[i-1]
          local line = math.floor((point.y) / (map.tileSize * map.scale)) + 1
          local column = math.floor((point.x) / (map.tileSize * map.scale)) + 1
          
          if self.mapCopy[line][column] == 1 then
            self.mapCopy[line][column] = 10
          end
          if self.mapCopy[line][column-1] == 1 then
            self.mapCopy[line][column] = 10
          end
        end
      end]]
      
      if #self.pathPoints > 5 then
        table.remove(self.pathPoints, 1)
      end
      
      if self.type == "IA" then
        -- A la fin du compte à rebours, les tanks peuvent avancer
        if game.race_state == "IN_PROGRESS" then
          self.state = "MOVE_FORWARD"
        end
        
        -- Utilisation de capteurs pour ajuster la trajectoire
        -- Collision avec les capteurs
        for i=1, 3 do
          if self.sensors[i].line >= 1 and self.sensors[i].line <= map.height and
          self.sensors[i].column >= 1 and self.sensors[i].column <= map.width then
            if map.level[self.sensors[i].line][self.sensors[i].column] == 0 then
              self.sensors[i].collide = true
            else
              self.sensors[i].collide = false
            end
          end
        end
        
        if self.sensors[1].collide then
          if self.sensors[3].collide == false then
            self.angle = self.angle + 90 * dt
            if self.angle > 360 then
              self.angle = 1
            end
          end
          if self.sensors[2].collide == false then
            self.angle = self.angle - 90 * dt
            if self.angle <= 0 then
              self.angle = 360
            end
          end
        end
        
        if self.sensors[2].collide then
          self.angle = self.angle + 90 * dt
          if self.angle > 360 then
            self.angle = 1
          end
        end
        
        if self.sensors[3].collide then
          self.angle = self.angle - 90 * dt
          if self.angle <= 0 then
            self.angle = 360
          end
        end
        
        if self.sensors[1].collide and self.sensors[3].collide then
          if self.sensors[2].collide == false then
            self.angle = self.angle - 90 * dt
            if self.angle <= 0 then
              self.angle = 360
            end
          end
        end
        
        -- Si les 3 capteurs sont TRUE, tank bloqué
        if self.sensors[1].collide and self.sensors[2].collide and self.sensors[3].collide then
          self.angle = self.angle - 90 * dt
          if self.angle <= 0 then
            self.angle = 360
          end
        end
        
         -- Recherche des bonus
        for i=1, #bonusList do
          local bonus = bonusList[i]
          if self.bonusSensor.x - 64 < bonus.xo and self.bonusSensor.x + 64 > bonus.xo and self.bonusSensor.y - 64 < bonus.yo and self.bonusSensor.y + 64 > bonus.yo then
            
            --if self.life < self.maxLife then
              --if bonusList[i].category == "repair" then
                local bonusAngle = math.deg(math.angle(self.x, self.y, bonus.xo, bonus.yo))
                if bonusAngle < 0 then
                  bonusAngle = 360 + bonusAngle
                end
                if self.angle < bonusAngle then
                  self.angle = self.angle + 90 * dt
                end
                if self.angle > bonusAngle then
                  self.angle = self.angle - 90 * dt
                end
              --end
            --end
          end
        end
        
        
        
        -- Décalage par rapport à un joueur devant sa position
        for i=1, #ia_list do
          local player = ia_list[i]
          if i ~= self.ID then
            if self.passSensor.x - 32 < player.x and self.passSensor.x + 32 > player.x and self.passSensor.y - 32 < player.y and self.passSensor.y + 32 > player.y then
              local rand = math.random(0, 1)
              if rand == 1 then
                self.angle = self.angle + 90 * dt
              else 
                self.angle = self.angle - 90 * dt
              end
            end
          end
        end
      end
    
      -- Vérification de la position sur le circuit
      self.line = math.floor((self.cameraY - map.cameraY) / (map.tileSize * map.scale)) + 1
      self.column = math.floor((self.cameraX - map.cameraX) / (map.tileSize * map.scale)) + 1
      
      -- Contrôler la ligne de départ pour incrémenter les tours
      if map.level[self.line][self.column] == 2 and self.newLap == true then
        self.lap = self.lap + 1
        self.newLap = false
      end
      if map.level[self.line][self.column] == 4 and self.newLap == false then
        self.newLap = true
      end
      -- Si tout les tours sont faits, on arrête le tank
      if self.lap >= map.level.maxLaps then
        -- Le timer est incrémenter pour laisser le temps de passer la ligne, puis arrêt
        tank.chrono = time.chrono
        self.timer = self.timer + dt
        if self.timer >= 1 then
          self.state = "STOP"
          tank.finish = true
        end
      end
      
      -- Collision avec les tiles
      if self.line >= 1 and self.line <= 20 and self.column >= 1 and self.column <= 20 then
        -- Si il n'y a pas de collision
        local bounce = 2 -- rebond contre les murs
        
        if self.collide then
          self.collide = false
        end
        
        -- Haut
        if self.y - 16 <= (self.line-1) * map.tileSize and map.level[self.line-1][self.column] == 0 then
          self.collide = true
          self.y = (((self.line-1) * map.tileSize) + self.size / 2) + bounce
        end
        -- Bas
        if self.y + 16 >= (self.line) * map.tileSize and map.level[self.line+1][self.column] == 0 then
          self.collide = true
          self.y = (((self.line) * map.tileSize) - self.size / 2) - bounce
        end
        -- Gauche
        if self.x - 16 <= (self.column-1) * map.tileSize and map.level[self.line][self.column-1] == 0 then
          self.collide = true
          self.x = (((self.column-1) * map.tileSize) + self.size / 2) + bounce
        end
        -- Droite
        if self.x + 16 >= (self.column) * map.tileSize and map.level[self.line][self.column+1] == 0 then
          self.collide = true
          self.x = (((self.column) * map.tileSize) - self.size / 2) - bounce
        end
      end
      
      -- Gestion des dégâts
      -- On retire en pourcentage à la vitesse max du tank, le nombre de dégats. 
      if self.life <= self.maxLife then
        local speed = self.maxSpeed - (self.maxSpeed * ((self.maxLife - self.life) / 2)) / 100
        if self.speed >= speed then
          self.speed = speed
        end
      end
      
      -- Condition de fin de vie
      if self.life <= 0 then
        self.life = 0
        self.state = "STOP"
        self.destroy = true
      end
    end
  end
  
  -- Gestion des bonus
  function tank:addBonus(pCategory, pValue)
    if pCategory == "ammo" then
      self.ammo = self.ammo + pValue
    elseif pCategory == "dollar" then
      game.money = game.money + pValue
      self.money = game.money
    elseif pCategory == "repair" then
      self.life = self.life + 10
      if self.life >= self.maxLife then
        self.life = 100
      end
    end
  end
  
  function tank:addTrail()
    local trail = {}
    trail.x = self.x
    trail.y = self.y
    trail.angle = self.angle
    table.insert(self.trailList, trail)
  end
  
  function tank:removeTrail()
    for i=#self.trailList, trailLength, -1 do
      if i > trailLength then
        table.remove(self.trailList, 1)
      end
    end
  end
  
  function tank:addPathPoint(pX, pY)
    local point = {}
      point.x = pX
      point.y = pY
      point.area = 0
    table.insert(self.pathPoints, point)
  end
  
  function tank:addBullet()
    local bullet = {}
      bullet.x = self.x
      bullet.y = self.y
      bullet.angle = self.turret.angle
      bullet.collide = false
    table.insert(self.bulletList, bullet)
  end
  
  function tank:removeBullet(pID)
    for i=#self.bulletList, 1, -1 do
      if i == pID then
        table.remove(self.bulletList, pID)
      end
    end
  end
  
  function tank:drawTrails()
    -- Trace des chenilles
    for i=1, #self.trailList do
      love.graphics.draw(self.trailImage, self.trailList[i].x, self.trailList[i].y, math.rad(self.trailList[i].angle), 1, 1, 0, 16)
    end
  end
  
  function tank:drawPath()
    for i=1, #self.pathPoints do
      love.graphics.circle("line", self.pathPoints[i].x, self.pathPoints[i].y, self.pathPoints[i].area*2)
    end
  end
  
  function tank:takeDammage()
    self.life = self.life - 10
  end
  
  function tank:draw()
    --self:drawPath()
    if tank.state == "STOP" then
      love.graphics.draw(self.img, self.sprite[1], self.x, self.y, math.rad(self.angle), 1, 1, 16, 16)
    end
    if tank.state == "MOVE_FORWARD" or tank.state == "SLOW" or tank.state == "SLOW" then
      love.graphics.draw(self.img, self.sprite[math.floor(tank.imgCurrent)], self.x, self.y, math.rad(self.angle), 1, 1, 16, 16)
    elseif tank.state == "MOVE_FORBACK" then
      love.graphics.draw(self.img, self.sprite[math.floor(tank.imgCurrent)], self.x, self.y, math.rad(self.angle), 1, 1, 16, 16)
    end
    
    -- Obus
    for i=1, #self.bulletList do
      love.graphics.draw(self.bulletImage, self.bulletList[i].x, self.bulletList[i].y, self.bulletList[i].angle, 0.5, 0.5, 0, 3)
    end
    
    -- Tourelle
    love.graphics.draw(tank.turretImg, tank.turretSpr, self.x, self.y, self.turret.angle, 1, 1, 14, 16)
  
    --love.graphics.circle("line", self.passSensor.x, self.passSensor.y, 32)
  
    -- Affichage des capteurs
    if debug then
      if self.collide then
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle("line", self.x, self.y, 14)
      else
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("line", self.x, self.y, 16)
      end
      
      for i=1, #self.sensors do
        if self.sensors[i].collide then
          love.graphics.setColor(255, 0, 0)
          love.graphics.circle("fill", self.sensors[i].x, self.sensors[i].y, 4)
        else
          love.graphics.setColor(255, 255, 255)
          love.graphics.circle("line", self.sensors[i].x, self.sensors[i].y, 4)
        end
      end
      
      love.graphics.setColor(255, 255, 255)
    end
  end
  
  function tank:drawPathDebug()
    local x = map.x 
    local y = map.y 
    for l=1, #self.mapCopy do
      for c=1, #self.mapCopy[1] do
        if self.mapCopy[l][c] == 10 then
          love.graphics.setColor(255, 255, 255, 100)
          love.graphics.rectangle("fill", x, y, map.tileSize, map.tileSize)
        end
        x = x + map.tileSize
      end
      x = map.x 
      y = y + map.tileSize
    end
  end
  
  function tank:drawDebug()
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("front : "..tostring(self.sensors[1].collide), 10, 30)
    love.graphics.print("left : "..tostring(self.sensors[2].collide), 10, 50)
    love.graphics.print("right : "..tostring(self.sensors[3].collide), 10, 70)
    love.graphics.print("x"..self.mouse.x, 10, 90)
    love.graphics.print("y"..self.mouse.y, 10, 110)
    love.graphics.print("x"..self.x, 10, 130)
    love.graphics.print("y"..self.y, 10, 150)
  end
  
  function tank:mousepressed(x, y, btn)
    if btn == 1 and self.shoot == false and self.ammo > 0 then
      self.shoot = true
    end
  end
  
  return tank
end

return tank