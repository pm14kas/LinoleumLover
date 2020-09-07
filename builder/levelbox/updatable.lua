updatable = {
    type = "block"
}

function updatable:new(data)
    data = data or {}
    setmetatable(data, self)
    self.__index = self
    return o
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
        h = self.h
    }
end

function updatable:fieldResizeW()
    return {
        x = self.x - self:getBorderWidth(),
        y = self.y - self:getBorderWidth(),
        w = self:getBorderWidth(),
        h = self.h
    }
end

function updatable:fieldResizeS()
    return {
        x = self.x - self:getBorderWidth(),
        y = self.y + self.h,
        w = self.w,
        h = self:getBorderWidth()
    }
end

function updatable:fieldResizeN()
    return {
        x = self.x - self:getBorderWidth(),
        y = self.y - self:getBorderWidth(),
        w = self.w,
        h = self:getBorderWidth()
    }
end

function updatable:setProperty(prop, val)
    self[prop] = val
end
