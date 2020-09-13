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
                local newSpawn = {
                    x = block.x,
                    y = block.y,
                    w = block.w,
                    h = block.h,
                    link = "",
                    c = { 1, 1, 1 },
                    target = "",
                    name = name
                }
                levelbox:getMap(map).spawns[name] = newSpawn
                block.saveTo = "spawns"
                return newSpawn
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
                local newPortal = {
                    x = block.x,
                    y = block.y,
                    w = block.w,
                    h = block.h,
                    link = "",
                    spawn = "",
                    c = { 1, 0, 1 },
                    name = name
                }
                levelbox:getMap(map).targets[name] = newPortal
                block.saveTo = "portals"
                return newPortal
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
                block.entityType = contextMenu.screens["forDoor"].categories[1].types[2].sign
                block.saveTo = "doors"
                table.insert(levelbox:getMap(map).doors, name)
            end,
            save = function(name, arrayToSave, map)
            end,
        }
    }
}

require("classes.levelbox.load")
require("classes.levelbox.levelView")
require("classes.levelbox.mapView")

function levelbox:getStep()
    return {
        w = self.step.w * self.step.mult,
        h = self.step.h * self.step.mult,
    }
end

function levelbox:load()
    self:loadBasic()
    self:loadGame()
    --self:loadHelpers()
    self:loadState()
    self:loadMaps()
    self:loadLinks()
    
    self:highlightBlock()
    self:selectBlock()
    self:selectMap()
    
    self.scaleMin = 1 / math.max(self:getActiveMap().sizeX, self:getActiveMap().sizeY)
    self.w = screen:get("levelbox").w * self:getActiveMap().sizeX
    self.h = screen:get("levelbox").h * self:getActiveMap().sizeY
    self:centrize()
    self.game = nil
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
    local spawn = block.name or block.spawn or block
    map = map or block.map or self.state.activeMap
    return self:getMap(map).spawns[spawn]
end

function levelbox:getTarget(block, map)
    local target = block.name or block.target or block
    map = map or block.map or self.state.activeMap
    return self:getMap(map).targets[target]
end

function levelbox:makeActiveSpawn()
    if self.state.selectedBlock and self:getSelectedBlock().type == "Spawn" then
        self.state.activeSpawn = self.state.selectedBlock
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
        self:selectBlock()
        self.state.activeMap = nil
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
            self.state.activeMap = self.state.selectedMap
            self.scaleMin = 1 / math.max(self:getActiveMap().sizeX, self:getActiveMap().sizeY)
            self.w = screen:get("levelbox").w * self:getActiveMap().sizeX
            self.h = screen:get("levelbox").h * self:getActiveMap().sizeY
    
            print(self:getActiveMap().offset.x)
            self.scale = self:getActiveMap().scale
            self.offsetX = self:getActiveMap().offset.x
            self.offsetY = self:getActiveMap().offset.y
        end
        self.grabbedMap = nil
        self:selectMap()
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
        local newIndex = "link" .. (self.state.linksCount + 1)
        self.links[newIndex] = { spawn = spawn, target = target }
        self:getTarget(target).spawn = self:getSpawn(spawn).name
        self:getSpawn(spawn).link = newIndex
        self:getTarget(target).link = newIndex
        self:setLinkmode(false)
        self.state.linksCount = self.state.linksCount + 1
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
        for k, map in self:orderBy("z", self.state.maps) do
            map:draw()
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
                self:getSpawn(link.spawn).x *
                    self:getMap(link.spawn.map).w / self.w /
                    self:getMap(link.spawn.map).sizeX +
                    self:getMap(link.spawn.map).x,
                self:getSpawn(link.spawn).y * self:getMap(link.spawn.map).h / self.h / self:getMap(link.spawn.map).sizeY + self:getMap(link.spawn.map).y,
                self:getTarget(link.target).x * self:getMap(link.target.map).w / self.w / self:getMap(link.target.map).sizeX + self:getMap(link.target.map).x,
                self:getTarget(link.target).y * self:getMap(link.target.map).h / self.h / self:getMap(link.target.map).sizeY + self:getMap(link.target.map).y
            )
        end
    else
        love.graphics.setColor(self:getActiveMap().backgroundColor)
        love.graphics.rectangle("fill", 0, 0, self.w, self.h)
        for kblock, block in self:orderBy("z", self:getActiveMap().blocks) do
            block:draw()
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
        activeSpawn = self.state.activeSpawn,
        maps = {}
    }
    for kmap, map in pairs(self.state.maps) do
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
                save.maps[kmap][block.saveTo] = {}
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
    
    local savefile = io.open("mapForBuilder.linoleum", "w")
    io.output(savefile)
    io.write(json.encode(self.state))
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
        self:getGrabbedBlock():update()
    elseif self.grabbedMap then
        self:getGrabbedMap():update()
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