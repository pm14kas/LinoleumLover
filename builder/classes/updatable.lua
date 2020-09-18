updatable = {}

require("classes.updatable.update")

function updatable:new(data)
    data = data or {}
    setmetatable(data, self)
    self.__index = self
    return data
end

function updatable:get()
    return self
end

function updatable:getBorderWidth()
    return (self.border + self.borderW / 2) / levelbox.scale
end

function updatable:fieldResizeE()
    return {
        x = self.x + self.w,
        y = self.y - self:getBorderWidth(),
        w = self:getBorderWidth(),
        h = self.h + 2 * self:getBorderWidth()
    }
end

function updatable:fieldResizeW()
    return {
        x = self.x - self:getBorderWidth(),
        y = self.y - self:getBorderWidth(),
        w = self:getBorderWidth(),
        h = self.h + 2 * self:getBorderWidth()
    }
end

function updatable:fieldResizeS()
    return {
        x = self.x - self:getBorderWidth(),
        y = self.y + self.h,
        w = self.w + 2 * self:getBorderWidth(),
        h = self:getBorderWidth()
    }
end

function updatable:fieldResizeN()
    return {
        x = self.x - self:getBorderWidth(),
        y = self.y - self:getBorderWidth(),
        w = self.w + 2 * self:getBorderWidth(),
        h = self:getBorderWidth()
    }
end

function updatable:select()
    self.selected = true
end

function updatable:unselect()
    self.selected = false
end

function updatable:highlight()
    self.highlighted = true
end

function updatable:unhighlight()
    self.highlighted = false
end


function updatable:setProperty(prop, val)
    self[prop] = val
end

function updatable:move(dx, dy)
    self:setProperty("x", math.min(math.max(0, self.x + dx), levelbox.w - self.w))
    self:setProperty("y", math.min(math.max(0, self.y + dy), levelbox.h - self.h))
end

function updatable:pushPreviousState()
    table.insert(self.previousStates, {
        x = self.x,
        y = self.y,
        w = self.w,
        h = self.h
    })
end

function updatable:popPreviousState()
    table.remove(self.previousStates)
end