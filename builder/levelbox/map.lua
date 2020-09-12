require("updatable")

map = updatable:new()

function map:draw()
    local valueScale = 50 / graphikFont:getHeight() / 10
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    if self.selected then
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