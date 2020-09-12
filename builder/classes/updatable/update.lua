function updatable:resize(dir)
    if love.mouse.isDown(1) then
        levelbox.resize[dir] = true
        local dx = cursor.x - self.grabbedX
        local dy = cursor.y - self.grabbedY
        self.grabbedX = cursor.x
        self.grabbedY = cursor.y
        if dir == "E" then self:resizeE(dx, dy) end
        if dir == "W" then self:resizeW(dx, dy) end
        if dir == "S" then self:resizeS(dx, dy) end
        if dir == "N" then self:resizeN(dx, dy) end
    else
        levelbox.resize[dir] = false
    end
end

function updatable:resizeE(dx, dy)
    self:setProperty("w", math.min(math.max(0, self.w + dx), levelbox.w - self.x))
end

function updatable:resizeW(dx, dy)
    if self.x > 0 then
        self:setProperty("w", math.min(math.max(0, self.w - dx), levelbox.w - self.x))
    end
    if self.w > 0 then
        self:setProperty("x", math.min(math.max(0, self.x + dx), levelbox.w - self.w))
    end
end

function updatable:resizeS(dx, dy)
    self:setProperty("h", math.min(math.max(0, self.h + dy), levelbox.h - self.y))
end

function updatable:resizeN(dx, dy)
    if self.y > 0 then
        self:setProperty("h", math.min(math.max(0, self.h - dy), levelbox.h - self.y))
    end
    if self.h > 0 then
        self:setProperty("y", math.min(math.max(0, self.y + dy), levelbox.h - self.h))
    end
end

function updatable:grab()
    if love.mouse.isDown(1) then
        levelbox:setGrab(true)
        local dx = cursor.x - self.grabbedX
        local dy = cursor.y - self.grabbedY
        self:move(dx, dy)
    else
        levelbox:setGrab(false)
    end
end

function updatable:align()
    self:setProperty("x", customRound(self.x, levelbox:getStep().w))
    self:setProperty("y", customRound(self.y, levelbox:getStep().h))
    self:setProperty("w", customRound(self.w, levelbox:getStep().w))
    self:setProperty("h", customRound(self.h, levelbox:getStep().h))
    self.grabbedX = customRound(self.grabbedX, levelbox:getStep().w)
    self.grabbedY = customRound(self.grabbedY, levelbox:getStep().w)
end

function updatable:update()
    if cursor.inside(self:fieldResizeE()) and not levelbox.grab or levelbox.resize.E then
        love.mouse.setCursor(cursorWE)
        self:resize("E")
    elseif cursor.inside(self:fieldResizeW()) and not levelbox.grab or levelbox.resize.W then
        love.mouse.setCursor(cursorWE)
        self:resize("W")
    elseif cursor.inside(self:fieldResizeS()) and not levelbox.grab or levelbox.resize.S then
        love.mouse.setCursor(cursorNS)
        self:resize("S")
    elseif cursor.inside(self:fieldResizeN()) and not levelbox.grab or levelbox.resize.N then
        love.mouse.setCursor(cursorNS)
        self:resize("N")
    else
        if not love.mouse.isDown(1) then
            levelbox.resize.W = false
            levelbox.resize.E = false
            levelbox.resize.S = false
            levelbox.resize.N = false
            love.mouse.setCursor(cursorSt)
        end
    end
    if not levelbox.resize.W and not levelbox.resize.E and not levelbox.resize.S and not levelbox.resize.N then
        self:grab()
    end
    if not love.mouse.isDown(1) then
        self:align()
    end
end