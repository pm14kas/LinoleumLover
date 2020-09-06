function levelbox:resizeUpdatable(updatable, dir)
    if love.mouse.isDown(1) then
        self.resize[dir] = true
        local dx = cursor.x - updatable.grabbedX
        local dy = cursor.y - updatable.grabbedY
        updatable.grabbedX = cursor.x
        updatable.grabbedY = cursor.y
        if dir == "E" then self:resizeUpdatableE(updatable, dx, dy) end
        if dir == "W" then self:resizeUpdatableW(updatable, dx, dy) end
        if dir == "S" then self:resizeUpdatableS(updatable, dx, dy) end
        if dir == "N" then self:resizeUpdatableN(updatable, dx, dy) end
    else
        self.resize[dir] = false
    end
end

function levelbox:resizeUpdatableE(updatable, dx, dy)
    self:setUpdatableProperty(updatable, "w", math.min(math.max(0, updatable.w + dx), self.w - updatable.x))
end

function levelbox:resizeUpdatableW(updatable, dx, dy)
    if updatable.x > 0 then
        self:setUpdatableProperty(updatable, "w", math.min(math.max(0, updatable.w - dx), self.w - updatable.x))
    end
    if updatable.w > 0 then
        self:setUpdatableProperty(updatable, "x", math.min(math.max(0, updatable.x + dx), self.w - updatable.w))
    end
end

function levelbox:resizeUpdatableS(updatable, dx, dy)
    self:setUpdatableProperty(updatable, "h", math.min(math.max(0, updatable.h + dy), self.h - updatable.y))
end

function levelbox:resizeUpdatableN(updatable, dx, dy)
    if updatable.y > 0 then
        self:setUpdatableProperty(updatable, "h", math.min(math.max(0, updatable.h - dy), self.h - updatable.y))
    end
    if updatable.h > 0 then
        self:setUpdatableProperty(updatable, "y", math.min(math.max(0, updatable.y + dy), self.h - updatable.h))
    end
end

function levelbox:moveUpdatable(updatable, dx, dy)
    self:setUpdatableProperty(updatable, "x", math.min(math.max(0, updatable.x + dx), self.w - updatable.w))
    self:setUpdatableProperty(updatable, "y", math.min(math.max(0, updatable.y + dy), self.h - updatable.h))
    if updatable.updatableType == "block" then
        self:stickUpdatable(updatable)
    else
        updatable.grabbedX = cursor.x
        updatable.grabbedY = cursor.y
    end
end

function levelbox:stickUpdatable(updatable)
    local stuck = { x = false, y = false }
    local stuckWith = { w = 10 * self.step.w, h = 10 * self.step.h }
    for kupdatable, otherUpdatable in pairs(self:getActiveMap().blocks) do
        if kupdatable ~= updatable.name then
            if between(-stuckWith.w, otherUpdatable.x - (updatable.x + updatable.w), stuckWith.w) and
                (otherUpdatable.y < updatable.y + updatable.h and updatable.y < otherUpdatable.y + otherUpdatable.h)
            then
                updatable.x = otherUpdatable.x - updatable.w
                stuck.x = true
            elseif between(-stuckWith.w, updatable.x - (otherUpdatable.x + otherUpdatable.w), stuckWith.w) and
                (otherUpdatable.y < updatable.y + updatable.h and updatable.y < otherUpdatable.y + otherUpdatable.h)
            then
                updatable.x = otherUpdatable.x + otherUpdatable.w
                stuck.x = true
            elseif between(-stuckWith.h, otherUpdatable.y - (updatable.y + updatable.h), stuckWith.h) and
                (otherUpdatable.x < updatable.x + updatable.w and updatable.x < otherUpdatable.x + otherUpdatable.w)
            then
                updatable.y = otherUpdatable.y - updatable.h
                stuck.y = true
            elseif between(-stuckWith.h, updatable.y - (otherUpdatable.y + otherUpdatable.h), stuckWith.h) and
                (otherUpdatable.x < updatable.x + updatable.w and updatable.x < otherUpdatable.x + otherUpdatable.w)
            then
                updatable.y = otherUpdatable.y + otherUpdatable.h
                stuck.y = true
            end
        end
    end
    if not stuck.x then
        updatable.grabbedX = cursor.x
    end
    if not stuck.y then
        updatable.grabbedY = cursor.y
    end
end

function levelbox:grabUpdatable(updatable)
    if love.mouse.isDown(1) then
        self:setGrab(true)
        local dx = cursor.x - updatable.grabbedX
        local dy = cursor.y - updatable.grabbedY
        self:moveUpdatable(updatable, dx, dy)
    else
        self:setGrab(false)
    end
end

function levelbox:alignUpdatable(updatable)
    self:setUpdatableProperty(updatable, "x", customRound(updatable.x, self:getStep().w))
    self:setUpdatableProperty(updatable, "y", customRound(updatable.y, self:getStep().h))
    self:setUpdatableProperty(updatable, "w", customRound(updatable.w, self:getStep().w))
    self:setUpdatableProperty(updatable, "h", customRound(updatable.h, self:getStep().h))
    updatable.grabbedX = customRound(updatable.grabbedX, self:getStep().w)
    updatable.grabbedY = customRound(updatable.grabbedY, self:getStep().w)
end

function levelbox:updateUpdatable(updatable)
    if cursor.inside(self:updatableFieldResizeE(updatable)) and not self.grab or self.resize.E then
        love.mouse.setCursor(cursorWE)
        self:resizeUpdatable(updatable, "E")
    elseif cursor.inside(self:updatableFieldResizeW(updatable)) and not self.grab or self.resize.W then
        love.mouse.setCursor(cursorWE)
        self:resizeUpdatable(updatable, "W")
    elseif cursor.inside(self:updatableFieldResizeS(updatable)) and not self.grab or self.resize.S then
        love.mouse.setCursor(cursorNS)
        self:resizeUpdatable(updatable, "S")
    elseif cursor.inside(self:updatableFieldResizeN(updatable)) and not self.grab or self.resize.N then
        love.mouse.setCursor(cursorNS)
        self:resizeUpdatable(updatable, "N")
    else
        if not love.mouse.isDown(1) then
            self.resize.W = false
            self.resize.E = false
            self.resize.S = false
            self.resize.N = false
            love.mouse.setCursor(cursorSt)
        end
    end
    if not self.resize.W and not self.resize.E and not self.resize.S and not self.resize.N then
        levelbox:grabUpdatable(updatable)
    end
    if not love.mouse.isDown(1) then
        levelbox:alignUpdatable(updatable)
    end
end