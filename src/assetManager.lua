local assetManager = {}

assetManager.images = {}

function assetManager:loadImage(name, path)
  self.images[name] = love.graphics.newImage(path)
end

function assetManager:getImage(name)
  return self.images[name]
end

function assetManager:loadAssets()
  self:loadImage("bulletIcon", "assets/img/bullet_icon.png")
  self:loadImage("bombIcon", "assets/img/bomb_icon.png")

  -- bonus
  self:loadImage("ammo", "assets/img/ammo_box.png")
  self:loadImage("money", "assets/img/dollar.png")
  self:loadImage("repair", "assets/img/repair.png")

  -- tiles
  self:loadImage("dirt", "assets/img/dirt_tilable.png")
  self:loadImage("startLine", "assets/img/start.png")
  self:loadImage("concrete", "assets/img/concrete.png")

  -- vehicles
  self:loadImage("trail", "assets/img/trail.png")
  self:loadImage("bullet", "assets/img/bullet.png")
  self:loadImage("tank", "assets/img/tank.png")
  self:loadImage("turret", "assets/img/turret.png")

  print(self.images['dirt'])
end

return assetManager