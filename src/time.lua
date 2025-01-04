local time = {}
  time.chrono = 0
  time.start = false
  
  function time:resetChrono()
    self.chrono = 0
  end
  
  function time:startChrono() -- ui_race
    self.start = true
    self.stop = false
  end
  
  function time:stopChrono()
    self.stop = true
    self.start = false
  end
  
  function time:update(dt) -- main
    if self.start then
      self.chrono = self.chrono + dt
    end
  end
  
  function time:draw() -- main, à afficher dans ui_tank
    love.graphics.print(math.floor(self.chrono), 10, 20)
  end
  
return time