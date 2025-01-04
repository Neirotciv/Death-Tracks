local ui = {}

local function newElement(pX, pY)
  local element = {}
    element.x = pX
    element.y = pY
    element.visible = true
    
    function element:setVisible(pVisible)
      self.visible = pVisible
    end
    
   function element:setPosition(pX, pY)
    self.x = pX
    self.y = pY
  end
    
    function element:draw()
      print("element:draw() / nothing")
    end
  return element
end

function ui.newPanel(pX, pY, pW, pH)
  local panel = newElement(pX, pY)
    panel.width = pW
    panel.height = pH
    panel.image = nil
    panel.backGroundColor = { 1, 1, 1, 1 }
    panel.outlineColor = { 1, 1, 1, 1 }
    panel.borderRadius = 0
    panel.borderLineWidth = 1
    panel.scale = 1
    panel.drawBackground = true
    panel.lastEvents = {}
    
  function panel:setEvent(pEvent, pFunction)
    self.lastEvents[pEvent] = pFunction
  end
  
  function panel:setScale(pScale)
    self.scale = pScale
  end
    
  function panel:setDimensions(pWidth, pHeight)
    self.width = pWidth
    self.height = pHeight
  end  
  
  function panel:setBackgroundColor(pR, pG, pB, pA)
    self.backGroundColor = { pR, pG, pB, pA }
  end
  
  function panel:setOutlineColor(pR, pG, pB, pA)
    self.outlineColor = { pR, pG, pB, pA }
  end
  
  function panel:setImage(pImage)
    self.image = pImage
    self.w = pImage:getWidth()
    self.h = pImage:getHeight()
  end
  
  function panel:setBorderRadius(pRadius)
    self.borderRadius = pRadius
  end
  
  function panel:setBorderLineWidth(pWidth)
    self.borderLineWidth = pWidth
  end
  
  function panel:setDrawBackground(pBool)
    self.drawBackground = pBool
  end
  
  function panel:updatePanel(dt)
    local mX, mY = love.mouse.getPosition()
    if mX > self.x and mX < self.x + (self.width * self.scale) and mY > self.y and mY < self.y + (self.height * self.scale) then
      if self.hover == false then
        self.hover = true
      end
    else 
      if self.hover then
        self.hover = false
      end
    end
  end
  
  function panel:update(dt)
    self:updatePanel(dt)
  end
  
  function panel:drawPanel()
    love.graphics.push()
    if self.Image == nil then
      -- Background
      if self.drawBackground then
        love.graphics.setColor(self.backGroundColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width * self.scale, self.height * self.scale, self.borderRadius)
      end
      love.graphics.setLineStyle( "rough" )
      love.graphics.setLineWidth(self.borderLineWidth)
      love.graphics.setColor(self.outlineColor)
      love.graphics.rectangle("line", self.x, self.y, self.width * self.scale, self.height * self.scale, self.borderRadius)
    else
      love.graphics.draw(self.image, self.x, self.y)
    end
    love.graphics.pop()
  end
  
  function panel:draw()
    if self.visible then
      self:drawPanel()
      
      for i=1, self.totalElements do
        self.elements[i]:draw()
      end
    end
  end
  
  return panel
end

function ui.newFrame(pX, pY, pWidth, pHeight)
  local frame = ui.newPanel(pX, pY, pWidth, pHeight)
    frame.elements = {}
    frame.totalElements = 0
    
  function frame:setCenter(pName, pAlignement)
    -- Remplacer par un foreach
    for i=1, #self.elements do
      if self.elements[i].name == pName then
        local element = self.elements[i]
        if pAlignement == "horizontal" then
          local ecart = self.width - element.width
          element.x = (self.x + (self.width / 2)) - (element.width / 2)
        end
      end
    end
  end
  
  function frame:addElement(pX, pY, pElement)
    local element = pElement
    
    -- Si un élement existe déja, on place le dernier sous le précedent
    if self.totalElements > 1 then
      
    end
    
    -- Positionnement de l'élément par rapport à la frame
    pElement:setPosition(self.x + pX, self.y + pY)
    
    -- Si l'élément possède un label
    if pElement.label ~= nil then
      pElement.label.x = self.x + pX
      pElement.label.y = self.y + pY
    end
    
    --self.width = pElement.width * pElement.scale
    
    table.insert(self.elements, element)
    self.totalElements = #self.elements
  end
  
  function frame:setAlignement()
    for i=1, #self.elements do
      if i == 1 then
        self.elements[i].x = self.x
        self.elements[i].y = self.y
      end
    end
  end
  
  function frame:update(dt)
    for n, value in pairs(self.elements) do
      if value ~= nil then
        value:update(dt)
      else
        print("update function not implemented")
      end
    end
  end
  
  return frame
end

function ui.newToolBar(pX, pY, pAlignment)
  local toolBar = {}
    toolBar.x = pX
    toolBar.y = pY
    toolBar.alignment = pAlignment or "horizontal"
    toolBar.width = 0
    toolBar.height = 0
    toolBar.borderRadius = 0
    toolBar.scale = 1
    toolBar.borderLineWidth = 1
    toolBar.backGroundColor = {0.98, 0.98, 0.98, 1}
    toolBar.outlineColor = {1, 1, 1, 1}
    toolBar.icons = {}
    toolBar.margin = {}
      toolBar.margin.top = 5
      toolBar.margin.bottom = 5
      toolBar.margin.left = 5
      toolBar.margin.right = 5
      toolBar.margin.icon = 5
    toolBar.isVisible = true
    
  function toolBar:setPosition(pX, pY)
    self.x = pX
    self.y = pY
  end
  
  function toolBar:setBorderRadius(pRadius)
    self.borderRadius = pRadius
  end
  
  function toolBar:setAlignment()
    if self.alignment == "horizontal" then
      self.height = self.icons[1].height + self.margin.bottom + self.margin.bottom
      local width = self.margin.left
      
      for i=1, #self.icons do
        width = width + self.icons[i].width + self.margin.icon
        self.icons[i].y = self.y + self.margin.top
        if i == 1 then
          -- Positionnement de la première icône à partir de la marge de gauche
          self.icons[i].x = self.x + self.margin.left
        elseif i > 1 then
          self.icons[i].x = self.icons[i-1].x + self.icons[i-1].width + self.margin.icon
        end
      end
    
      -- Rajout de la marge de droite
      self.width = width + self.margin.right - self.margin.icon
    end
    
    if self.alignment == "vertical" then
      self.width = self.icons[1].width + self.margin.left + self.margin.right
      local height = self.margin.top
      for i=1, #self.icons do
        height = height + self.icons[i].height + self.margin.icon
        self.icons[i].x = self.x + self.margin.left
        if i == 1 then
          -- Positionnement de la première icône à partir de la marge de gauche
          self.icons[i].y = self.y + self.margin.top
        elseif i > 1 then
          self.icons[i].y = self.icons[i-1].y + self.icons[i-1].height + self.margin.icon
        end
      end
      
      -- Rajout de la marge du bas
      self.height = height + self.margin.bottom - self.margin.icon
    end
  end
  
  function toolBar:setMargin(pTop, pBottom, pLeft, pRight, pIcon)
    toolBar.margin.top = pTop
    toolBar.margin.bottom = pBottom
    toolBar.margin.left = pLeft
    toolBar.margin.right = pRight
    toolBar.margin.icon = pIcon
  end
  
  function toolBar:setWidth(pWidth)
    self.width = pWidth
  end
  
  function toolBar:setDimensions(pWidth, pHeight)
    self.width = pWidth
    self.height = pHeight
  end
  
  function toolBar:setBackgroundColor(pR, pG, pB, pA)
    self.backGroundColor = { pR, pG, pB, pA }
  end
  
  function toolBar:setOutlineColor(pR, pG, pB, pA)
    self.outlineColor = { pR, pG, pB, pA }
  end
  
  function toolBar:setVisible(pVisible)
    self.isVisible = pVisible
  end
  
  function toolBar:addIcon(pIcon)
    table.insert(self.icons, pIcon)
    self:setAlignment(self.alignment)
  end
  
  function toolBar:update(dt)
    for n, value in pairs(self.icons) do
      if value ~= nil then
        value:update(dt)
      else
        print("update function not implemented")
      end
    end
  end
  
  function toolBar:draw()
    if self.isVisible then
      love.graphics.setColor(self.backGroundColor)
      love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.borderRadius)
      love.graphics.setLineWidth(2)
      love.graphics.setColor(self.outlineColor)
      love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.borderRadius)
      
      for n, value in pairs(self.icons) do
        if value ~= nil then
          value:draw()
        else
          print("draw function not implemented")
        end
      end
    else
      -- Aucun affichage
    end
  end
  
  return toolBar
end

function ui.newIcon(pX, pY, pImage, pScale)
  local icon = {}
    icon.x = pX
    icon.y = pY
    icon.imageDefault = love.graphics.newImage(pImage)
    icon.imageHover = nil
    icon.imagePressed = nil
    icon.scale = pScale or 1
    icon.width = icon.imageDefault:getWidth() * icon.scale
    icon.height = icon.imageDefault:getHeight() * icon.scale
    icon.hover = false
    icon.pressed = false
    icon.oldButtonState = false
    icon.sound = nil
    icon.lastEvents = {}
   
  function icon:setSound(pSource)
    self.sound = pSource
  end
    
  function icon:setScale(pScale)
    self.scale = pScale
    icon.width = icon.imageDefault:getWidth() * icon.scale
    icon.height = icon.imageDefault:getHeight() * icon.scale
  end
  
  function icon:setImage(pHover, pPressed)
    icon.imageHover = love.graphics.newImage(pHover)
    icon.imagePressed = love.graphics.newImage(pPressed)
  end
  
  function icon:setEvent(pEventType, pFunction)
    self.lastEvents[pEventType] = pFunction
  end
  
  function icon:update(dt)
    local mx, my = love.mouse.getPosition()
    
    if mx > self.x and mx < self.x + self.width and my > self.y and my < self.y + self.height then
      if self.hover == false then
        self.hover = true
        if self.lastEvents["hover"] ~= nil then
          self.lastEvents["hover"]("begin")
        end
      end
    else
      if self.hover == true then
        self.hover = false
        if self.lastEvents["hover"] ~= nil then
          self.lastEvents["hover"]("end")
        end
      end
    end
    
    if self.hover and love.mouse.isDown(1) and self.pressed == false and self.oldButtonState == false then
      self.pressed = true
      if self.lastEvents["pressed"] ~= nil then
        self.lastEvents["pressed"]()
      end
      if self.sound ~= nil then
        self.sound:play()
      end
    else
      if self.pressed == true and love.mouse.isDown(1) == false then
        self.pressed = false
        --if self.lastEvents["pressed"] ~= nil then
          --self.lastEvents["pressed"]()
        --end
      end
    end
    
    self.oldButtonState = love.mouse.isDown(1)
  end
  
  function icon:draw()
    love.graphics.setColor(1, 1, 1)
    
    -- Image par défaut si elle n'est pas survolée
    if self.hover == false then
      love.graphics.draw(self.imageDefault, self.x, self.y, 0, self.scale, self.scale)
    end
    -- Changement de l'image si elle existe et qu'elle est survolée
    if self.hover then
      if self.imageHover ~= nil then
        love.graphics.draw(self.imageHover, self.x, self.y, 0, self.scale, self.scale)
      else
        -- Si l'image survolé n'existe pas, on affiche un cadre autour
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.imageDefault, self.x, self.y, 0, self.scale, self.scale)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
      end
    end
    -- Changement de l'image si l'icône est cliquée
    if self.pressed then
      if self.imagePressed ~= nil then
        love.graphics.draw(self.imagePressed, self.x, self.y, 0, self.scale, self.scale)
      end
    end
  end
  
  return icon
end

function ui.newLabel(pX, pY, pW, pH, pText, pFont, pHAlign, pVAlign)
  local label = ui.newPanel(pX, pY, pW, pH)
    label.text = pText
    label.font = pFont
    label.color = nil
    label.textWidth = pFont:getWidth(pText)
    label.textHeight = pFont:getHeight(pText)
    label.horizontalAlign = pHAlign
    label.verticalAlign = pVAlign
    label.scale = 1
    label.textScale = 1
  
  function label:setTextScale(pScale)
    self.textScale = pScale
  end
  
  function label:updateText(pText)
    self.text = pText
  end
  
  function label:reload()
    self.textWidth = pFont:getWidth(self.text)
    self.textHeight = pFont:getHeight(self.text)
  end
  
  function label:drawText()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    local x = self.x
    local y = self.y
    
    if self.horizontalAlign == "center" then
      x = x + ((self.width - self.textWidth) / 2)
    elseif self.horizontalAlign == "left" then
      x = self.x
    end
    if self.verticalAlign == "center" then
      y = y + ((self.height - self.textHeight) / 2)
    end
    
    love.graphics.print(self.text, x, y, 0, self.textScale, self.textScale)
  end
  
  function label:draw()
    if self.visible == false then return end
    self:drawText()
  end
    
  return label
end

function ui.newButton(pX, pY, pWidth, pHeight, pText, pFont)
  local button = ui.newPanel(pX, pY, pWidth, pHeight)
    button.x = pX
    button.y = pY
    button.text = pText
    button.label = ui.newLabel(pX, pY, pWidth, pHeight, pText, pFont, "center", "center")
    
    button.imgDefault = nil
    button.imgHover = nil
    button.imgPressed = nil
    
    button.hover = false
    button.pressed = false
    button.oldButtonState = false
    button.lastEvent = {}
    
    button:setBackgroundColor(0.39, 0.39, 0.39, 1)
    button:setBorderRadius(5)
    button:setBorderLineWidth(2)
      
  function button:setImages(pImageDefault, pImageHover, pImagePressed)
    self.imgDefault = love.graphics.newImage(pImageDefault)
    self.imgHover = love.graphics.newImage(pImageHover)
    self.imgPressed = love.graphics.newImage(pImagePressed)
    self.width =  self.imgDefault:getWidth()
    self.height =  self.imgDefault:getHeight()
  end
  
  function button:setEvent(pEventType, pFunction)
    self.lastEvents[pEventType] = pFunction
  end
  
  function button:update(dt)
    self:updatePanel(dt)
    
    if self.hover and love.mouse.isDown(1) and self.pressed == false and self.oldButtonState == false then
      self.pressed = true
      if self.lastEvents["pressed"] ~= nil then
        self.lastEvents["pressed"]()
        self.pressed = false
      end
    else
      if self.pressed == true and love.mouse.isDown(1) == false then
        self.pressed = false
      end
    end
    
    self.oldButtonState = love.mouse.isDown(1)
  end
    
  function button:draw()
    if self.pressed then
      if self.imgPressed == nil then
        self:drawPanel()
        love.graphics.setColor(1, 1, 1, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      else
        love.graphics.draw(self.imgPressed, self.x, self.y, 0, self.scale, self.scale)
      end
    elseif self.hover then
      if self.imgHover == nil then
        self:drawPanel()
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", self.x-2, self.y-2, self.width+4, self.height+4)
      else
        love.graphics.draw(self.imgHover, self.x, self.y, 0, self.scale, self.scale)
      end
    else
      if self.imgDefault == nil then
        self:drawPanel()
      else
        love.graphics.draw(self.imgDefault, self.x, self.y, 0, self.scale, self.scale)
      end
    end
    self.label:drawText()
  end
  
  return button
end

function ui.newCheckbox(pX, pY, pWidth, pHeight, pPressed)
  local checkbox = ui.newPanel(pX, pY, pWidth, pHeight)
    checkbox.x = pX
    checkbox.y = pY
    
    checkbox.imgDefault = nil
    checkbox.imgPressed = nil
    
    checkbox.hover = false
    checkbox.pressed = pPressed or false
    checkbox.oldButtonState = false
    checkbox.lastEvent = {}
    
    checkbox.checkSound = nil
    checkbox.uncheckSound = nil
    
  function checkbox:setImages(pImageDefault, pImagePressed)
    self.imgDefault = love.graphics.newImage(pImageDefault)
    self.imgPressed = love.graphics.newImage(pImagePressed)
    self.width = self.imgDefault:getWidth()
    self.height = self.imgDefault:getHeight()
  end
  
  function checkbox:setSounds(pCheck, pUncheck)
    checkbox.checkSound = pCheck
    checkbox.uncheckSound = pUncheck
  end
  
  function checkbox:setPosition(pX, pY)
    self.x = pX
    self.y = pY
  end
  
  function checkbox:setState(pBool)
    self.pressed = pBool
  end
  
  function checkbox:update(dt)
    self:updatePanel(dt)
    
    if self.hover and love.mouse.isDown(1) and self.pressed == false and self.oldButtonState == false then
      self.pressed = true
      if self.lastEvents["pressed"] ~= nil then
        self.lastEvents["pressed"](true)
      end
      if self.checkSound ~= nil then
        checkbox.checkSound:play()
      end
    else
      if self.hover and love.mouse.isDown(1) and self.pressed and self.oldButtonState == false then
        self.pressed = false
        self.lastEvents["pressed"](false)
        
        if self.uncheckSound ~= nil then
          checkbox.uncheckSound:play()
        end
      end
    end
    
    self.oldButtonState = love.mouse.isDown(1)
  end
    
  function checkbox:draw()
    if self.pressed then
      if self.imgPressed == nil then
        self:drawPanel()
        love.graphics.setColor(1, 1, 1, 0.19)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      else
        love.graphics.draw(self.imgPressed, self.x, self.y, 0, self.scale, self.scale)
      end
    else
      if self.imgDefault == nil then
        self:drawPanel()
      else
        love.graphics.draw(self.imgDefault, self.x, self.y, 0, self.scale, self.scale)
      end
    end
  end
  
  return checkbox
end

-- Width restera identique qu'elle que soit le scale
function ui.newSlider(pX, pY, pWidth, pScale, pLabel)
  local slider = {}
    slider.x = pX
    slider.y = pY
    slider.scale = pScale
    slider.width = pWidth
    slider.label = pLabel or nil
      
    slider.value = {}
      slider.value.min = 0
      slider.value.max = 100
      slider.value.current = 0
    
    slider.decimal = false
    slider.hover = false
    slider.pressed = false
    slider.oldButtonState = false
    slider.lastEvents = {}
      
  function slider:setImages(pCursor, pBar, pLeft, pRight)
    slider.leftSide = {}
      slider.leftSide.image = love.graphics.newImage(pLeft)
      slider.leftSide.x = self.x
    
    slider.imageWidth = self.leftSide.image:getWidth() * self.scale
    slider.imageHeight = self.leftSide.image:getWidth() * self.scale
    
    slider.bar = {}
      slider.bar.image = love.graphics.newImage(pBar) -- Sera étiré avec un scale sur l'axe y
      slider.bar.x = self.x + self.imageWidth
    
    slider.cursor = {}
      slider.cursor.image = love.graphics.newImage(pCursor)
      slider.cursor.x = self.x
      slider.cursor.y = self.y
      slider.cursor.width = slider.cursor.image:getWidth() * self.scale
      slider.cursor.height = slider.cursor.image:getHeight() * self.scale
      slider.cursor.xo = slider.bar.x - (slider.cursor.width / 2) + (self.value.current * (self.width / self.value.max))
      slider.cursor.yo = self.y + (slider.imageHeight - slider.cursor.height) / 2
      
    slider.rightSide = {}
      slider.rightSide.image = love.graphics.newImage(pRight)
      slider.rightSide.x = slider.bar.x + self.width
  end
  
  function slider:setPosition(pX, pY)
    self.x = pX
    self.y = pY
    
    -- Recalcul de la position de tout les élements du slider
    slider.leftSide.x = self.x
    slider.bar.x = self.x + self.imageWidth
    slider.cursor.x = self.x
    slider.cursor.y = self.y
    slider.cursor.xo = slider.bar.x - (slider.cursor.width / 2)
    slider.cursor.yo = self.y + (slider.imageHeight - slider.cursor.height) / 2
    slider.rightSide.x = slider.bar.x + self.width
  end
  
  function slider:setValues(pMin, mMax, pValue)
    self.value.min = pMin
    self.value.max = mMax
    self.value.current = pValue
    self.cursor.xo = (self.bar.x - self.cursor.width / 2) + (self.value.current * (self.width / self.value.max))
  end
  
  function slider:setEvent(pEvent, pFunction)
    self.lastEvents[pEvent] = pFunction
  end
  
  function slider:setDecimal(pBool)
    self.decimal = pBool
  end
  
  function slider:getValue()
    return self.value.current
  end
  
  function slider:update(dt)
    local mX, mY = love.mouse.getPosition()
    
    if mX > self.cursor.xo and mX < self.cursor.xo + self.cursor.width and mY > self.cursor.yo and mY < self.cursor.yo + self.cursor.height or
    mX > self.bar.x and mX < self.rightSide.x and mY > self.cursor.yo and mY < self.cursor.yo + self.cursor.height then
      if self.hover == false then
        self.hover = true
      end
    else
      if self.hover then
        self.hover = false
      end
    end
    
    if self.hover and love.mouse.isDown(1) and self.pressed == false and self.oldButtonState == false then
      self.pressed = true
      self.cursor.xo = mX
    else
      if self.pressed == true and love.mouse.isDown(1) == false then
        self.pressed = false
        if self.lastEvents["pressed"] ~= nil then
          self.lastEvents["pressed"](self.value.current)
        end
      end
    end
    
    if self.pressed then
      self.cursor.xo = mX - (self.cursor.width / 2)
      -- Blocage du curseur si il sort en dehors de la barre
      if self.cursor.xo <= self.bar.x - self.cursor.width / 2 then
        self.cursor.xo = self.bar.x - (slider.cursor.width / 2)
      elseif self.cursor.xo >= self.rightSide.x - self.cursor.width / 2 then
        self.cursor.xo = self.rightSide.x - self.cursor.width / 2
      end
      
      -- Ajustement de la valeur du slider par rapport à la position du curseur
      if self.decimal then
        self.value.current = self.value.min + (((self.cursor.xo + self.cursor.width / 2) - self.bar.x) / self.width) * (self.value.max - self.value.min)
      elseif self.decimal == false then
        self.value.current = math.floor(self.value.min + (((self.cursor.xo + self.cursor.width / 2) - self.bar.x) / self.width) * (self.value.max - self.value.min))
      end
    end
    
    self.oldButtonState = love.mouse.isDown(1)
  end
  
  function slider:debug()
    love.graphics.rectangle("line", self.x, self.y, self.imageWidth,  self.imageHeight)
    love.graphics.rectangle("line", self.bar.x, self.y, self.width, self.imageHeight)
    love.graphics.rectangle("line", self.rightSide.x, self.y, self.imageWidth,  self.imageHeight)
    love.graphics.rectangle("line", self.cursor.xo, self.cursor.yo, self.cursor.width,  self.cursor.height)
  end
  
  function slider:draw()
    local widthScale = self.width / (self.imageWidth / self.scale)
    --self.cursor.xo = (self.bar.x - self.cursor.width / 2) + (self.value.current * (self.width / self.value.max)) -- MODIFIER ÇA
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.leftSide.image, self.x, self.y, 0, self.scale, self.scale)
    love.graphics.draw(self.bar.image, self.bar.x, self.y, 0, widthScale, self.scale)
    love.graphics.draw(self.rightSide.image, self.rightSide.x, self.y, 0, self.scale, self.scale)
    love.graphics.draw(self.cursor.image, self.cursor.xo, self.cursor.yo, 0, self.scale, self.scale)
    
    if self.label ~= nil then
      love.graphics.print(self.label, self.bar.x - self.cursor.width / 2, self.y - 15)
    end
    
    if self.decimal then
      love.graphics.print(string.format("%.2f", self.value.current), self.rightSide.x + self.imageWidth/2, self.y+7)
    elseif self.decimal == false then
      love.graphics.print(math.floor(self.value.current), self.rightSide.x + self.imageWidth/2, self.y+7)
    end
    --self:debug()
  end
  
  return slider
end

return ui