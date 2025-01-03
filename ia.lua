local tank = require("tank")

local ia = {}

function ia.new(pX, pY)
  local myIA = tank.newTank(pX, pY)
  myIA.state = "MOVE_FORWARD"
  myIA.type = "IA"
  
  function myIA:moveForward()
    if self.state == "STOP" then
      self.state = "MOVE_FORWARD"
    else
      self.state = "STOP"
    end
  end
  
  function myIA:reloadBeforeRace()
    self.life = self.maxLife
    self.destroy = false
    self.state = "STOP"
  end
  
  return myIA
end

return ia