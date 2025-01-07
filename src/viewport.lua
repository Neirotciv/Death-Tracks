local viewport = {}

local canvas
local gameWidth, gameHeight
local scaleX, scaleY
local offsetX, offsetY

function viewport.init(gameWidth, gameHeight)
  canvas = love.graphics.newCanvas(gameWidth, gameHeight)
  local screenWidth, screenHeight = love.window.getDesktopDimensions()
  love.window.setMode(screenWidth, screenHeight, {fullscreen = true})

  scaleX = screenWidth / gameWidth
  scaleY = screenHeight / gameHeight
  local minScale = math.min(scaleX, scaleY)

  scaleX, scaleY = minScale, minScale
  offsetX = (screenWidth - gameWidth * scaleX) / 2
  offsetY = (screenHeight - gameHeight * scaleY) / 2
end

function viewport.start()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
end

function viewport.finish()
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(canvas, offsetX, offsetY, 0, scaleX, scaleY)
end

return viewport