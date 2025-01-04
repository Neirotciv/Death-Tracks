local camera = {}
  camera.position = {}
    camera.position.x = 0
    camera.position.y = 0
  camera.timer = 0
  camera.scale = 1
  
function camera:set()
  love.graphics.push()
  if camera.scale == 1 then
    love.graphics.scale(1, 1)
    love.graphics.translate(-self.position.x, - self.position.y)
  elseif camera.scale == 2 then -- A voir plus tard
    love.graphics.scale(.4, .4)
    love.graphics.translate(-self.position.x, - self.position.y)
  end
end

function camera:setScale()
  if self.scale == 1 then
    self.scale = 2
  else
    self.scale = 1
  end
end

function camera:unset()
  love.graphics.pop()
end

return camera