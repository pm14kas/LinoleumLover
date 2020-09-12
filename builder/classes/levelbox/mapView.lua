function levelbox:getSelectedMap()
    return self:getMap(self.state.selectedMap)
end

function levelbox:getMap(map)
    return self.state.maps[map]
end

function levelbox:drawMap(name)
    local map = self:getMap(name)
    local valueScale = 50 / graphikFont:getHeight() / 10
    love.graphics.setColor(map.backgroundColor)
    love.graphics.rectangle("fill", map.x, map.y, map.w, map.h)
    if name == self.state.selectedMap then
        love.graphics.setLineWidth(map.borderW / self.scale)
        love.graphics.rectangle("line", map.x - map.border / self.scale, map.y - map.border / self.scale,
                                map.w + map.border / self.scale * 2, map.h + map.border / self.scale * 2)
        love.graphics.setLineWidth(1)
        
        love.graphics.setColor(1 - map.backgroundColor[1], 1 - map.backgroundColor[2], 1 - map.backgroundColor[3])
        love.graphics.setFont(graphikFont)
        love.graphics.printf(
            "z = " .. map.z,
            map.x,
            map.y,
            map.w / valueScale,
            "left",
            0,
            valueScale,
            valueScale
        )
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(graphikFont)
    love.graphics.printf(
        map.value .. "(" .. map.sizeX .. "x" .. map.sizeY .. ")",
        map.x,
        map.y - 5,
        map.w / valueScale,
        "center",
        0,
        valueScale,
        valueScale
    )
    love.graphics.translate(
        map.x,
        map.y
    )
    love.graphics.scale(
        map.w / self.w / map.sizeX,
        map.h / self.h / map.sizeY
    )
    for kspawn, spawn in pairs(self.state.maps[name].spawns) do
        love.graphics.setColor(spawn.c)
        love.graphics.rectangle("fill", spawn.x, spawn.y, spawn.w, spawn.h)
    end
    for ktarget, target in pairs(self.state.maps[name].targets) do
        love.graphics.setColor(target.c)
        love.graphics.rectangle("fill", target.x, target.y, target.w, target.h)
    end
    love.graphics.scale(
        self.w / map.w * map.sizeX,
        self.h / map.h * map.sizeY
    )
    love.graphics.translate(
        -map.x,
        -map.y
    )
end

function levelbox:getActiveMap()
    return self.state.maps[self.state.activeMap]
end

function levelbox:newMap(sizeX, sizeY)
    if self:getMapView() then
        local name = "map" .. self.state.mapsCount + 1
        self.state.maps[name] = {
            x = (cursor.x - self.offsetX) / self.scale,
            y = (cursor.y - self.offsetY) / self.scale,
            z = 1,
            w = 30 * sizeX,
            h = 30 * sizeY,
            sizeX = sizeX,
            sizeY = sizeY,
            border = 10,
            borderW = 5,
            grabbedX = 25,
            grabbedY = 50,
            value = "m" .. self.state.mapsCount + 1,
            type = "Map",
            maps = {},
            spawns = {},
            targets = {},
            offset = { x = 0, y = 0 },
            scale = 1,
            backgroundColor = { 1, 1, 1 },
            mapsCount = 0,
            name = name,
            updatableType = "map"
        }
        self.state.mapsCount = self.state.mapsCount + 1
        self.state.selectedMap = name
        self.grabbedMap = name
    end
end

function levelbox:getGrabbedMap()
    return self:getMap(self.grabbedMap)
end

function levelbox:selectMap(map)
    if self.state.selectedMap then
        self:getSelectedMap():unselect()
    end
    self.state.selectedMap = map
    if map then
        self:getMap(map):select()
    end
end