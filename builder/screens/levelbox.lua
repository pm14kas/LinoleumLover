screen:new("levelbox", {
    w = w * 3 / 4,
    h = h * 3 / 4,
    -- scaleX = w * 3 / 4 / layout.w,
    -- scaleY = h * 3 / 4 / layout.h,
    active = true,
    draw = true
})
function screen.s.levelbox:show()
    love.graphics.rectangle("line", 0, 0, math.floor(self.w), math.floor(self.h))
    love.graphics.translate(levelbox.offsetX, levelbox.offsetY)
    love.graphics.scale(levelbox.scale)
    cursor.x = (cursor.x - levelbox.offsetX) / levelbox.scale
    cursor.y = (cursor.y - levelbox.offsetY) / levelbox.scale
    
    levelbox:update()
    levelbox:draw()
    
    cursor.y = (cursor.y * levelbox.scale) + levelbox.offsetY
    cursor.x = (cursor.x * levelbox.scale) + levelbox.offsetX
    love.graphics.scale(1 / levelbox.scale)
    love.graphics.translate(-levelbox.offsetX, -levelbox.offsetY)
end

levelbox = {
    blockTypes = {
        Block = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.entityType = "Solid"
                block.saveTo = "blocks"
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].entityType = block.entityType
            end
        },
        Spawn = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.value = "S"
                block.w = 20
                block.h = 20
                block.color = { 0.1, 0.1, 0.1 }
                levelbox:getMap(map).spawns[name] = {
                    x = block.x,
                    y = block.y,
                    w = block.w,
                    h = block.h,
                    link = "",
                    c = { 1, 1, 1 },
                    target = "",
                    name = name
                }
                block.saveTo = "spawns"
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
            end,
        },
        Portal = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.value = "P"
                block.color = { 1, 1, 1 }
                levelbox:getMap(map).targets[name] = {
                    x = block.x,
                    y = block.y,
                    w = block.w,
                    h = block.h,
                    link = "",
                    spawn = "",
                    c = { 1, 0, 1 },
                    name = name
                }
                block.saveTo = "portals"
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].spawn = levelbox:getMap(map).targets[name].spawn
            end
        },
        Checkpoint = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.color = { 0, 0, 0 }
                block.value = "C"
                block.saveTo = "checkpoints"
                levelbox:getMap(map).targets[name] = {
                    x = block.x,
                    y = block.y,
                    w = 100,
                    h = 200,
                    link = "",
                    spawn = "",
                    c = { 0.44, 0.95, 0 },
                    name = name
                }
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].spawn = levelbox:getMap(map).targets[name].spawn
            end
        },
        Hazard = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.color = { 1, 0, 0 }
                block.value = "H"
                block.saveTo = "hazards"
            end,
            save = function(name, arrayToSave, map)
            end,
        },
        AI = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.color = { 1, 0, 0 }
                block.value = "A"
                block.h = 50
                block.entityType = "enemy"
                block.saveTo = "ai"
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].entityType = block.entityType
            end,
        },
        Item = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.color = { 1, 1, 1 }
                block.value = "I"
                block.h = 50
                block.entityType = contextMenu.screens["forItem"].categories[1].types[1].sign
                block.saveTo = "items"
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].entityType = block.entityType
            end,
        },
        Text = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.value = "Sample Text"
                block.h = 50
                block.z = -1e308
                block.saveTo = "decorations"
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].value = block.value
            end,
        },
        Button = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.h = 50
                block.w = 50
                block.saveTo = "buttons"
                block.color = { 1, 1, 1 }
                block.links = {}
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].links = block.links
            end,
        },
        Door = {
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.saveTo = "doors"
            end,
            save = function(name, arrayToSave, map)
            end,
        }
    }
}


function levelbox:getStep()
    return {
        w = self.step.w * self.step.mult,
        h = self.step.h * self.step.mult,
    }
end

function levelbox:load()
    self:loadBasic()
    self:loadGame()
    self:loadLinks()
    self:loadHelpers()
    
    self.state = {
        maps = {},
        activeSpawn = "",
        mapsCount = 0,
        linksCount = 0,
        activeMap = "map0",
        screenScale = { w = w / layout.w, h = h / layout.h }
    }
    
    if not self.game.linksCount then
        self.game.linksCount = #self.links
    end
    self.state.linksCount = self.game.linksCount
    if not self.game.screenScale then
        self.game.screenScale = { w = 1280 / layout.w, h = 720 / layout.h }
    end
    self.state.screenScale = self.game.screenScale
    self.step = { w = self.w / layout.w, h = self.h / layout.h, mult = 1, max = 99 }
    for kmap, map in pairs(self.game.maps) do
        self.state.maps[kmap] = map:new(map)
        if not self.game.activeMap then
            self.game.activeMap = kmap
        end
        for kblock, block in pairs(map.blocks) do
            self.state.maps[kmap] = map:new(map)
            if not block.z then
                block.z = 1
            end
            if not block.name then
                block.name = kblock
            end
            if not block.updatableType then
                block.updatableType = "block"
            end
            -----------------type conversion-----------------------
            if block.type == "block" then
                block.type = "Block"
            end
            if block.type == "spawn" then
                block.type = "Spawn"
            end
            if block.type == "hazard" then
                block.type = "Hazard"
            end
            if block.type == "target" then
                block.type = "Portal"
            end
            if block.type == "checkpoint" then
                block.type = "Checkpoint"
            end
            if block.type == "text" then
                block.type = "Text"
            end
            if block.type == "AI" then
                block.type = "AI"
            end
            if block.type == "item" then
                block.type = "Item"
            end
            -----------------/type conversion-----------------------
            -----------------other-----------------------
            if block.type == "Block" then
                block.saveTo = "blocks"
                if not block.entityType then
                    block.entityType = "Solid"
                end
            end
            if block.type == "Spawn" then
                block.saveTo = "spawns"
                if not block.entityType then
                    block.entityType = ""
                end
            end
            if block.type == "Hazard" then
                block.saveTo = "hazards"
                if not block.entityType then
                    block.entityType = ""
                end
            end
            if block.type == "Portal" then
                block.value = "P"
                block.saveTo = "portals"
                if not block.entityType then
                    block.entityType = ""
                end
            end
            if block.type == "Checkpoint" then
                block.saveTo = "checkpoints"
                if not block.entityType then
                    block.entityType = ""
                end
            end
            if block.type == "Text" then
                block.saveTo = "decorations"
                if not block.entityType then
                    block.entityType = ""
                end
            end
            if block.type == "AI" then
                block.saveTo = "ai"
                if not block.entityType then
                    block.entityType = "Enemy"
                end
            end
            if block.type == "Item" then
                block.saveTo = "items"
                if not block.entityType then
                    block.entityType = "Money"
                end
            end
            if not block.category then
                block.category = 1
            end
            if not block.innerType then
                block.innerType = 1
            end
            -----------------/other-----------------------
            block.x = customRound(block.x / self.game.screenScale.w * w / layout.w, self:getStep().w)
            block.y = customRound(block.y / self.game.screenScale.h * h / layout.h, self:getStep().h)
            block.w = customRound(block.w / self.game.screenScale.w * w / layout.w, self:getStep().w)
            block.h = customRound(block.h / self.game.screenScale.h * h / layout.h, self:getStep().h)
            block.grabbedX = customRound(block.grabbedX, self:getStep().w)
            block.grabbedY = customRound(block.grabbedY, self:getStep().h)
        end
        self.game.screenScale = { w = w / layout.w, h = h / layout.h }
        if not map.z then
            map.z = 1
        end
        if not map.sizeX then
            map.sizeX = 1
        end
        if not map.sizeY then
            map.sizeY = 1
        end
        if not map.scale then
            map.scale = 1
        end
        if not map.offset then
            map.offset = { x = 0, y = 0 }
        end
        if not map.name then
            map.name = kmap
        end
        if not map.updatableType then
            map.updatableType = "map"
        end
    end
    self.state.activeMap = self.game.activeMap
    
    for klink, link in pairs(levelbox.links) do
        local exists = false
        for kmap, map in pairs(levelbox.game.maps) do
            for kspawn, spawn in pairs(map.spawns) do
                if link.spawn.spawn == kspawn then
                    if exists then
                        levelbox:deletelink(klink)
                    else
                        exists = true
                        levelbox:getSpawn(kspawn, kmap).link = klink
                        levelbox:getTarget(link.target).link = klink
                    end
                end
            end
        end
    end
    self.scaleMin = 1 / math.max(self:getActiveMap().sizeX, self:getActiveMap().sizeY)
    self.w = screen:get("levelbox").w * self:getActiveMap().sizeX
    self.h = screen:get("levelbox").h * self:getActiveMap().sizeY
    self:centrize()
end

function levelbox:setGrab(flag)
    if flag then
        self.resize.W = false
        self.resize.E = false
        self.resize.S = false
        self.resize.N = false
    end
    self.grab = flag
end

function levelbox:getSpawn(block, map)
    local spawn = block.spawn or block
    map = map or block.map or self.game.activeMap
    return self:getMap(map).spawns[spawn]
end

function levelbox:getTarget(block, map)
    local target = block.target or block
    map = map or block.map or self.game.activeMap
    return self:getMap(map).targets[target]
end

function levelbox:makeActiveSpawn()
    if self.selectedBlock and self:getBlock(self.selectedBlock).type == "Spawn" then
        self.game.activeSpawn = self.selectedBlock
    end
end

function levelbox:setLinkmode(flag)
    if flag then
        levelbox:setGrab(false)
        self.resize.W = false
        self.resize.E = false
        self.resize.S = false
        self.resize.N = false
        self.linkMode = true
        self.UnlinkMode = false
    else
        self.linkingSpawn = nil
        self.linkingTarget = nil
        self.linkMode = false
    end
end

function levelbox:setUnLinkmode(flag)
    if flag then
        levelbox:setGrab(false)
        self.resize.W = false
        self.resize.E = false
        self.resize.S = false
        self.resize.N = false
        self.UnlinkMode = true
        self.linkMode = false
    else
        self.linkingSpawn = nil
        self.linkingTarget = nil
        self.UnlinkMode = false
    end
end

function levelbox:getLinkmode()
    return self.linkMode
end

function levelbox:getUnLinkmode()
    return self.UnlinkMode
end

function levelbox:centrize()
    self.scale = self.scaleMin
    self.offsetY = 0
    self.offsetX = 0
end

function levelbox:setMapView(flag)
    if flag then
        self:getActiveMap().scale = self.scale
        self:getActiveMap().offset.x = self.offsetX
        self:getActiveMap().offset.y = self.offsetY
        self.grabbedBlock = nil
        self.selectedBlock = nil
        self.game.activeMap = nil
        self.scaleMin = 1
        self.w = screen:get("levelbox").w
        self.h = screen:get("levelbox").h
        self.scale = self.mapView.scale
        self.offsetX = self.mapView.offset.x
        self.offsetY = self.mapView.offset.y
    else
        self.mapView.scale = self.scale
        self.mapView.offset.x = self.offsetX
        self.mapView.offset.y = self.offsetY
        if self:getMapView() then
            self.game.activeMap = self.selectedMap
            self.scaleMin = 1 / math.max(self:getActiveMap().sizeX, self:getActiveMap().sizeY)
            self.w = screen:get("levelbox").w * self:getActiveMap().sizeX
            self.h = screen:get("levelbox").h * self:getActiveMap().sizeY
            
            self.scale = self:getActiveMap().scale
            self.offsetX = self:getActiveMap().offset.x
            self.offsetY = self:getActiveMap().offset.y
        end
        self.grabbedMap = nil
        self.selectedMap = nil
    end
    self.mapView.set = flag
    itemView:triggerMapView(flag)
    contextMenu:setActiveScreen()
end

function levelbox:getMapView()
    return levelbox.mapView.set
end

function levelbox:link(spawn, target)
    local canPush = true
    for k, link in pairs(self.links) do
        canPush = link.target.target ~= target.target
        if not canPush then
            break
        end
    end
    if canPush then
        local newIndex = "link" .. (self.game.linksCount + 1)
        self.links[newIndex] = { spawn = spawn, target = target }
        self:getTarget(target).spawn = self:getSpawn(spawn).name
        self:getSpawn(spawn).link = newIndex
        self:getTarget(target).link = newIndex
        self:setLinkmode(false)
        self.game.linksCount = self.game.linksCount + 1
    end
end

function levelbox:getLink(link)
    return self.links[link]
end

function levelbox:deletelink(link)
    if self.links[link] then
        if self:getTarget(self.links[link].target) then
            self:getTarget(self.links[link].target).link = ""
        end
        if self:getSpawn(self.links[link].spawn) then
            self:getSpawn(self.links[link].spawn).link = ""
        end
    end
    self.links[link] = nil
end

function levelbox:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 0, 0, self.w, self.h)
    if self.getMapView() then
        for k, map in self:orderBy("z", self.game.maps) do
            self:drawMap(k)
        end
        
        love.graphics.setColor(0, 0, 0)
        if self.linkingSpawn then
            love.graphics.line(
                self:getSpawn(self.linkingSpawn).x * self:getMap(self.linkingSpawn.map).w / self.w / self:getMap(self.linkingSpawn.map).sizeX + self:getMap(self.linkingSpawn.map).x,
                self:getSpawn(self.linkingSpawn).y * self:getMap(self.linkingSpawn.map).h / self.h / self:getMap(self.linkingSpawn.map).sizeY + self:getMap(self.linkingSpawn.map).y,
                cursor.x,
                cursor.y
            )
        elseif self.linkingTarget then
            love.graphics.line(
                self:getTarget(self.linkingTarget).x * self:getMap(self.linkingTarget.map).w / self.w / self:getMap(self.linkingTarget.map).sizeX + self:getMap(self.linkingTarget.map).x,
                self:getTarget(self.linkingTarget).y * self:getMap(self.linkingTarget.map).h / self.h / self:getMap(self.linkingTarget.map).sizeY + self:getMap(self.linkingTarget.map).y,
                cursor.x,
                cursor.y
            )
        end
        
        for k, link in pairs(self.links) do
            love.graphics.line(
                self:getSpawn(link.spawn).x * self:getMap(link.spawn.map).w / self.w / self:getMap(link.spawn.map).sizeX + self:getMap(link.spawn.map).x,
                self:getSpawn(link.spawn).y * self:getMap(link.spawn.map).h / self.h / self:getMap(link.spawn.map).sizeY + self:getMap(link.spawn.map).y,
                self:getTarget(link.target).x * self:getMap(link.target.map).w / self.w / self:getMap(link.target.map).sizeX + self:getMap(link.target.map).x,
                self:getTarget(link.target).y * self:getMap(link.target.map).h / self.h / self:getMap(link.target.map).sizeY + self:getMap(link.target.map).y
            )
        end
    else
        love.graphics.setColor(self:getActiveMap().backgroundColor)
        love.graphics.rectangle("fill", 0, 0, self.w, self.h)
        for kblock, block in self:orderBy("z", self:getActiveMap().blocks) do
            self:drawBlock(kblock)
        end
        love.graphics.setLineWidth(0.01)
        if self.h * self.scale / layout.h > 6.5 then
            love.graphics.setColor(1, 1, 1)
            for i = 0, math.max(layout.w * self:getActiveMap().sizeX, layout.h * self:getActiveMap().sizeY) do
                love.graphics.line(
                    0,
                    i * self:getStep().h,
                    layout.w * self:getActiveMap().sizeX,
                    i * self:getStep().h
                )--horizontal
                
                love.graphics.line(
                    i * self:getStep().w,
                    0,
                    i * self:getStep().w,
                    layout.h * self:getActiveMap().sizeY
                )--vertical
            end
        end
        love.graphics.setColor(0, 0, 0)
        for i = 1, math.max(self:getActiveMap().sizeX, self:getActiveMap().sizeY) do
            love.graphics.line(
                0,
                i * self.h / self:getActiveMap().sizeY,
                self.w,
                i * self.h / self:getActiveMap().sizeY
            )--horizontal
            
            love.graphics.line(
                i * self.w / self:getActiveMap().sizeX,
                0,
                i * self.w / self:getActiveMap().sizeX,
                self.h
            )--vertical
        end
    end
    love.graphics.setLineWidth(1)
end

function levelbox:orderBy(key, array, order)
    if order then
        order = order:lower()
    else
        order = "asc"
    end
    local values = {}
    local keys = {}
    for k, v in pairs(array) do
        table.insert(values, v[key])
        table.insert(keys, k)
    end
    for i = 1, table.getn(values), 1 do
        for j = 1, table.getn(values), 1 do
            if ((order == "asc" and values[j] > values[i]) or (order == "desc" and values[j] < values[i])) then
                temp = values[i]
                values[i] = values[j]
                values[j] = temp
                temp = keys[i]
                keys[i] = keys[j]
                keys[j] = temp
            end
        end
    end
    local k = 0
    local iter = function()
        -- iterator function
        k = k + 1
        if keys[k] == nil then
            return nil
        else
            return keys[k], array[keys[k]]
        end
    end
    return iter
end

function levelbox:save()
    local save = {
        activeSpawn = self.game.activeSpawn,
        maps = {}
    }
    for kmap, map in pairs(self.game.maps) do
        save.maps[kmap] = {
            blocks = {},
            spawns = {},
            portals = {},
            checkpoints = {},
            hazards = {},
            decorations = {},
            ai = {},
            items = {},
            backgroundColor = map.backgroundColor,
            x = round(layout.getX(map.x)),
            y = round(layout.getY(map.y)),
            w = round(layout.getX(map.w)),
            h = round(layout.getY(map.h)),
            sizeX = map.sizeX,
            sizeY = map.sizeY
        }
        for kblock, block in pairs(map.blocks) do
            if not save.maps[kmap][block.saveTo] then
                error("Add arrays for new types!")
            end
            save.maps[kmap][block.saveTo][kblock] = {}
            save.maps[kmap][block.saveTo][kblock].x = layout.getX(block.x)
            save.maps[kmap][block.saveTo][kblock].y = layout.getY(block.y)
            save.maps[kmap][block.saveTo][kblock].w = layout.getX(block.w)
            save.maps[kmap][block.saveTo][kblock].h = layout.getY(block.h)
            save.maps[kmap][block.saveTo][kblock].color = block.color
            save.maps[kmap][block.saveTo][kblock].type = block.type
            self.blockTypes[block.type].save(kblock, save, kmap)
        end
    end
    savefile = io.open("mapForBuilder.linoleum", "w")
    io.output(savefile)
    io.write(json.encode(self.game))
    io.close(savefile)
    savefile = io.open("linksForBuilder.linoleum", "w")
    io.output(savefile)
    io.write(json.encode(self.links))
    io.close(savefile)
    savefile = io.open("map.linoleum", "wb")
    io.output(savefile)
    io.write(encrypt(json.encode(save), "Hui"))
    io.close(savefile)
    savefile = io.open("mapUnCyphered.linoleum", "wb")
    io.output(savefile)
    io.write(json.encode(save))
    io.close(savefile)
end

function levelbox:update()
    --love.mouse.setCursor(cursorSt)
    if love.keyboard.isDown("space") then
        self.grabbedBlock = nil
        self.grabbedMap = nil
        self.moving = true
    end
    if self.grabbedBlock then
        self:updateUpdatable(self:getGrabbedBlock())
    elseif self.grabbedMap then
        self:updateUpdatable(self:getGrabbedMap())
    else
        if love.mouse.isDown(1) then
            if self.moving then
                cursor.y = cursor.y * self.scale + self.offsetY
                cursor.x = cursor.x * self.scale + self.offsetX
                
                local dx = cursor.x - self.grabbedX
                local dy = cursor.y - self.grabbedY
                self.offsetX = math.min(math.max(-(self.w * self.scale - self.w * self.scaleMin), self.offsetX + dx), 0)
                self.offsetY = math.min(math.max(-(self.h * self.scale - self.h * self.scaleMin), self.offsetY + dy), 0)
                self.grabbedX = cursor.x
                self.grabbedY = cursor.y
                
                cursor.x = cursor.x - self.offsetX / self.scale
                cursor.y = cursor.y - self.offsetY / self.scale
            end
        end
    end
end