require("classes.updatable")

map = updatable:new()

function map:draw()
    local valueScale = 50 / graphikFont:getHeight() / 10
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    if self.selected or self.highlighted then
        love.graphics.setLineWidth(self.borderW / levelbox.scale)
        love.graphics.rectangle("line", self.x - self.border / levelbox.scale, self.y - self.border / levelbox.scale,
                                self.w + self.border / levelbox.scale * 2, self.h + self.border / levelbox.scale * 2)
        love.graphics.setLineWidth(1)
        
        love.graphics.setColor(1 - self.backgroundColor[1], 1 - self.backgroundColor[2], 1 - self.backgroundColor[3])
        love.graphics.setFont(graphikFont)
        love.graphics.printf(
            "z = " .. self.z,
            self.x,
            self.y,
            self.w / valueScale,
            "left",
            0,
            valueScale,
            valueScale
        )
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(graphikFont)
    love.graphics.printf(
        self.value .. "(" .. self.sizeX .. "x" .. self.sizeY .. ")",
        self.x,
        self.y - 5,
        self.w / valueScale,
        "center",
        0,
        valueScale,
        valueScale
    )
    love.graphics.translate(
        self.x,
        self.y
    )
    love.graphics.scale(
        self.w / levelbox.w / self.sizeX,
        self.h / levelbox.h / self.sizeY
    )
    for kspawn, spawn in pairs(self.spawns) do
        love.graphics.setColor(spawn.c)
        love.graphics.rectangle("fill", spawn.x, spawn.y, spawn.w, spawn.h)
    end
    for ktarget, target in pairs(self.targets) do
        love.graphics.setColor(target.c)
        love.graphics.rectangle("fill", target.x, target.y, target.w, target.h)
    end
    love.graphics.scale(
        levelbox.w / self.w * self.sizeX,
        levelbox.h / self.h * self.sizeY
    )
    love.graphics.translate(
        -self.x,
        -self.y
    )
end

function map:delete()
    for k, link in pairs(levelbox.links) do
        if link.spawn.map == self.name or link.target.map == self.name then
            levelbox:deletelink(k)
        end
    end
    self:unselect()
    levelbox.grabbedMap = nil
    levelbox.state.maps[self.name] = nil
end

function map:unselect()
    updatable.unselect(self)
    levelbox.state.selectedMap = nil
end

function map:move(dx, dy)
    updatable.move(self, dx, dy)
    self.grabbedX = cursor.x
    self.grabbedY = cursor.y
end

function map:setDefaults()
    if not self.doors then self.doors = {} end
    if not self.z then self.z = 1 end
    if not self.scale then self.scale = 1 end
    if not self.offset then self.offset = {x = 0, y = 0} end
    if not self.blocksCount then self.blocksCount = 0 end
    if not self.blocks then self.blocks = {} end
    if not self.spawns then self.spawns = {} end
    if not self.targets then self.targets = {} end
    if not self.doors then self.doors = {} end
    if not self.border then self.border = 10 end
    if not self.borderW then self.borderW = 5 end
    if not self.grabbedX then self.grabbedX = 25 end
    if not self.grabbedY then self.grabbedY = 50 end
    if not self.backgroundColor then self.backgroundColor = { 1, 1, 1 } end
    if not self.previousStates then self.previouseStates = {} end
end