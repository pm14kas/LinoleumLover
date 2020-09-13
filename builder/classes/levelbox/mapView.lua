function levelbox:getSelectedMap()
    return self:getMap(self.state.selectedMap)
end

function levelbox:getMap(map)
    return self.state.maps[map]
end

function levelbox:getActiveMap()
    return self.state.maps[self.state.activeMap]
end

function levelbox:newMap(sizeX, sizeY)
    if self:getMapView() then
        local name = "map" .. self.state.mapsCount + 1
        local newMap = map:new({
            x = (cursor.x - self.offsetX) / self.scale,
            y = (cursor.y - self.offsetY) / self.scale,
            w = 30 * sizeX,
            h = 30 * sizeY,
            sizeX = sizeX,
            sizeY = sizeY,
            value = "m" .. self.state.mapsCount + 1,
            name = name,
            type = "Map",
        })
        newMap:setDefaults()
        self.state.maps[name] = newMap
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