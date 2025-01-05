local ia = {}

-- Une ia est un tank
-- Réalise des actions

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

function ia.new(pX, pY)
  local self = tank.newTank(pX, pY)
  local parentUpdate = self.update

  self.sensors = {}
  self.sensors[1] = addSensor(pX, pY, 128, 0)   -- devant
  self.sensors[2] = addSensor(pX, pY, 128, 315) -- gauche
  self.sensors[3] = addSensor(pX, pY, 128, 45)  -- droite

  -- Proche
  self.sensors[4] = addSensor(pX, pY, 64, 0)
  self.sensors[5] = addSensor(pX, pY, 64, 330)
  self.sensors[6] = addSensor(pX, pY, 64, 30)

  self.bonusSensor = addSensor(pX, pY, 100, 0)
  self.passSensor = addSensor(pX, pY, 64, 0)

  self.state = "MOVE_FORWARD"
  self.type = "IA"

  function self:moveForward()
    if self.state == "STOP" then
      self.state = "MOVE_FORWARD"
    else
      self.state = "STOP"
    end
  end

  function self:update(dt)
    if game.race_state == "IN_PROGRESS" then
      self.state = "MOVE_FORWARD"

      self:updateAllSensors()
      self:adjustTrajectory(dt)
      self:overtakeTank(dt)
      self:avoidUTurn()
    end

    if parentUpdate then
      parentUpdate(self, dt)
    end
  end

  function self:updateAllSensors()
    for i=1, #self.sensors do
      self.sensors[i] = updateSensor(self.sensors[i], self.x, self.y, self.angle)
    end
    
    self.bonusSensor = updateSensor(self.bonusSensor, self.x, self.y, self.angle)
    self.passSensor = updateSensor(self.passSensor, self.x, self.y, self.angle)
  end

  -- TODO: voir ce que faisait le code commenté
  function self:overtakeTank(dt)
    -- IA POUR LE DEPASSEMENT - EN COURS
    -- if tankI.sensors[4].x >= (tankJ.x - (tankJ.size/2)) and tankI.sensors[4].x <= (tankJ.x + (tankJ.size/2))
    -- and tankI.sensors[4].y >= (tankJ.y - (tankJ.size/2)) and tankI.sensors[4].y <= (tankJ.y + (tankJ.size/2)) then
    --   tankI.sensors[4].collide = true
    -- else
    --   tankI.sensors[4].collide = false
    -- end

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

  -- TODO, ça ne fonctionne pas très bien
  function self:avoidUTurn()
    if self.pathTime >= 1 and self.halfTurn == false then
      if #self.pathPoints > 1 then
        self.pathPoints[#self.pathPoints-1].area = 32+10
      end
      self:addPathPoint(self.x, self.y)
      self.pathTime = 0
    end
  end

  function self:adjustTrajectory(dt)
    for i=1, 3 do
      -- Si on est bien sur la map
      if self.sensors[i].line >= 1 and self.sensors[i].line <= map.height and
      self.sensors[i].column >= 1 and self.sensors[i].column <= map.width then
        -- Détecter une collision avec un bloc
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
  end

  -- TODO: prioriser la réparation si dégats
  function gotToBonus()
    for i=1, #bonusList do
      local bonus = bonusList[i]
      if self.bonusSensor.x - 64 < bonus.xo and self.bonusSensor.x + 64 > bonus.xo 
      and self.bonusSensor.y - 64 < bonus.yo and self.bonusSensor.y + 64 > bonus.yo then
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
  end

  function self:reloadBeforeRace()
    self.life = self.maxLife
    self.destroy = false
    self.state = "STOP"
  end

  return self
end

return ia
