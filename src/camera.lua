local camera = {}
  camera.position = {x = 0, y = 0}
  camera.scale = 1
  camera.zoomLevels = {0.5, 1, 2}
  camera.zoomIndex = 2

function camera:set()
  love.graphics.push()
  if self.scale == self.zoomLevels[1] then
    love.graphics.scale(2, 2)
  elseif self.scale == self.zoomLevels[2] then
    love.graphics.scale(1, 1)
  elseif self.scale == self.zoomLevels[3] then
    love.graphics.scale(0.5, 0.5)
  end
  love.graphics.translate(-self.position.x, - self.position.y)
end

function camera:setScale()
  self.zoomIndex = self.zoomIndex % #self.zoomLevels + 1
  self.scale = self.zoomLevels[self.zoomIndex]
end

function camera:follow(targetX, targetY, screenWidth, screenHeight)
  local smooth = 0.1
  local targetXScreen = targetX - (screenWidth / 2) * self.scale
  local targetYScreen = targetY - (screenHeight / 2) * self.scale
  
  local deltaX = self.position.x - targetXScreen
  local deltaY = self.position.y - targetYScreen

  self.position.x = math.floor(self.position.x - (deltaX * smooth))
  self.position.y = math.floor(self.position.y - (deltaY * smooth))
end

function camera:unset()
  love.graphics.pop()
end

return camera