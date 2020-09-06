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
    x = screen:get("levelbox").X,
    y = screen:get("levelbox").Y,
    offsetX = screen:get("levelbox").X,
    offsetY = screen:get("levelbox").Y,
    w = screen:get("levelbox").w,
    h = screen:get("levelbox").h,
    moving = false,
    grabbedX = 25,
    grabbedY = 50,
    scale = 1,
    scaleMin = 1,
    scaleMax = 100,
    scaleStep = 0.1,
    scaleMult = 5,
    grabbedBlock = nil,
    selectedBlock = nil,
    grabbedMap = nil,
    selectedMap = nil,
    resize = {
        W = false,
        E = false,
        S = false,
        N = false
    },
    grab = false,
    linkMode = false,
    UnlinkMode = false,
    linkingSpawn = nil,
    linkingTarget = nil,
    links = file_exists("linksForBuilder.linoleum") and json.decode(read_file("linksForBuilder.linoleum")) or {},
    game = file_exists("mapForBuilder.linoleum") and json.decode(read_file("mapForBuilder.linoleum")) or
            {
                maps = {
                    ["map0"] = {
                        x = 0,
                        y = 0,
                        scale = 1,
                        offset = { x = 0, y = 0 },
                        sizeX = 1,
                        sizeY = 1,
                        w = 30,
                        h = 30,
                        border = 10,
                        borderW = 5,
                        color = { 1, 0, 0 },
                        grabbedX = 25,
                        grabbedY = 50,
                        value = "m0",
                        type = "map",
                        blocks = {},
                        spawns = {},
                        targets = {},
                        blocksCount = 0,
                        backgroundColor = { 1, 1, 1 }
                    },
                },
                activeSpawn = "",
                mapsCount = 0,
                linksCount = 0,
                activeMap = "map0",
                screenScale = { w = w / layout.w, h = h / layout.h }
            },
    mapView = {
        set = false,
        scale = 1,
        offset = { x = 0, y = 0 }
    },
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
                block.category = 1
                block.innerType = 1
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
        }
    }
}

function levelbox:load()
    if not self.game.linksCount then
        self.game.linksCount = #self.links
    end
    if not self.game.screenScale then
        self.game.screenScale = { w = 1280 / layout.w, h = 720 / layout.h }
    end
    self.step = { w = self.w / layout.w, h = self.h / layout.h }
    for kmap, map in pairs(self.game.maps) do
        if not self.game.activeMap then
            self.game.activeMap = kmap
        end
        for kblock, block in pairs(map.blocks) do
            if not block.z then
                block.z = 1
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
            block.x = customRound(block.x / self.game.screenScale.w * w / layout.w, self.step.w)
            block.y = customRound(block.y / self.game.screenScale.h * h / layout.h, self.step.h)
            block.w = customRound(block.w / self.game.screenScale.w * w / layout.w, self.step.w)
            block.h = customRound(block.h / self.game.screenScale.h * h / layout.h, self.step.h)
            block.grabbedX = customRound(block.grabbedX, self.step.w)
            block.grabbedY = customRound(block.grabbedY, self.step.h)
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
    end

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

function levelbox:getBlock(block, map)
    map = map or self.game.activeMap
    return self:getMap(map).blocks[block]
end

function levelbox:getSelectedBlock()
    return self:getBlock(self.selectedBlock)
end

function levelbox:getSelectedMap()
    return self:getMap(self.selectedMap)
end

function levelbox:selectBlock(block)
    if self.selectedBlock and button:exists("new" .. self:getSelectedBlock().entityType) then
        button:get("new" .. self:getSelectedBlock().entityType).color = button:get("new" .. self:getSelectedBlock().entityType).colorUnclicked
    end
    self.selectedBlock = block
    if block and button:exists("new" .. self:getSelectedBlock().entityType) then
        button:get("new" .. self:getSelectedBlock().entityType).color = button:get("new" .. self:getSelectedBlock().entityType).colorClicked
    end
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

function levelbox:getMap(map)
    return self.game.maps[map]
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
    self.step = { w = self.w / layout.w, h = self.h / layout.h }
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
    local valueScale = { mapView = (50 / graphikFont:getHeight() / 10), levelView = (50 / graphikFont:getHeight() / 3) }
    if self.getMapView() then
        for k, map in self:orderBy("z", self.game.maps) do
            love.graphics.setColor(map.backgroundColor)
            love.graphics.rectangle("fill", map.x, map.y, map.w, map.h)
            if k == self.selectedMap then
                love.graphics.setLineWidth(map.borderW / self.scale)
                love.graphics.rectangle("line", map.x - map.border / self.scale, map.y - map.border / self.scale, map.w + map.border / self.scale * 2, map.h + map.border / self.scale * 2)
                love.graphics.setLineWidth(1)

                love.graphics.setColor(1 - map.backgroundColor[1], 1 - map.backgroundColor[2], 1 - map.backgroundColor[3])
                love.graphics.setFont(graphikFont)
                love.graphics.printf(
                        "z = " .. map.z,
                        map.x,
                        map.y,
                        map.w / valueScale.mapView,
                        "left",
                        0,
                        valueScale.mapView,
                        valueScale.mapView
                )
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(graphikFont)
            love.graphics.printf(
                    map.value .. "(" .. map.sizeX .. "x" .. map.sizeY .. ")",
                    map.x,
                    map.y - 5,
                    map.w / valueScale.mapView,
                    "center",
                    0,
                    valueScale.mapView,
                    valueScale.mapView
            )
            love.graphics.translate(
                    map.x,
                    map.y
            )
            love.graphics.scale(
                    map.w / self.w / map.sizeX,
                    map.h / self.h / map.sizeY
            )
            for kspawn, spawn in pairs(self.game.maps[k].spawns) do
                love.graphics.setColor(spawn.c)
                love.graphics.rectangle("fill", spawn.x, spawn.y, spawn.w, spawn.h)
            end
            for ktarget, target in pairs(self.game.maps[k].targets) do
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
            love.graphics.setColor(block.color)
            if block.type == "Text" then
                love.graphics.setFont(graphikFont)
                love.graphics.printf(
                        block.value,
                        block.x,
                        block.y,
                        math.max(block.w, love.graphics.getFont():getWidth(block.value)),
                        "left",
                        0,
                        block.w / love.graphics.getFont():getWidth(block.value),
                        block.h / love.graphics.getFont():getHeight()
                )
                if kblock == self.selectedBlock then
                    love.graphics.setLineWidth(block.borderW / self.scale)
                    love.graphics.rectangle("line", block.x - block.border / self.scale, block.y - block.border / self.scale, block.w + block.border / self.scale * 2, block.h + block.border / self.scale * 2)
                    love.graphics.setLineWidth(1)
                end
            else
                if block.type == "Item" then
                    love.graphics.draw(
                            contextMenu.screens["forItem"].categories[block.category].types[block.innerType].picture,
                            block.x,
                            block.y,
                            0,
                            block.w / contextMenu.screens["forItem"].categories[block.category].types[block.innerType].picture:getWidth(),
                            block.h / contextMenu.screens["forItem"].categories[block.category].types[block.innerType].picture:getHeight()
                    )
                else
                    -- love.graphics.setFont(graphikFont)
                    -- love.graphics.printf(
                    -- 	"(" .. layout.getX(block.x + block.w) .. "x" .. layout.getY(block.y) .. ")",
                    -- 	block.x,
                    -- 	block.y + block.h + 5,
                    -- 	block.w / valueScale.levelView * 5,
                    -- 	"center",
                    -- 	0,
                    -- 	valueScale.levelView / 5
                    -- )
                    love.graphics.rectangle("fill", block.x, block.y, block.w, block.h)

                    love.graphics.setColor(0, 0, 0)
                    love.graphics.setLineWidth(3 * self.step.w)
                    love.graphics.rectangle("line", block.x + 3 / 2 * self.step.w, block.y + 3 / 2 * self.step.h, block.w - 3 * self.step.w, block.h - 3 * self.step.h) --x, y += offset + linewidth / 2; w, h -= 2 * offset + linewidth

                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setLineWidth(1 * self.step.w)
                    love.graphics.rectangle("line", block.x + (1 + 1 / 2) * self.step.w, block.y + (1 + 1 / 2) * self.step.h, block.w - 3 * self.step.w, block.h - 3 * self.step.h)

                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setFont(graphikFont)
                    love.graphics.printf(
                            block.value,
                            block.x,
                            block.y,
                            block.w / valueScale.levelView,
                            "center",
                            0,
                            valueScale.levelView,
                            valueScale.levelView
                    )
                end
                if kblock == self.selectedBlock then
                    love.graphics.setColor(block.color)
                    love.graphics.setLineWidth(block.borderW / self.scale)
                    love.graphics.rectangle("line", block.x - block.border / self.scale, block.y - block.border / self.scale, block.w + block.border / self.scale * 2, block.h + block.border / self.scale * 2)
                    love.graphics.setLineWidth(self.step.w)

                    love.graphics.setColor(1 - block.color[1], 1 - block.color[2], 1 - block.color[3])
                    love.graphics.setFont(graphikFont)
                    love.graphics.printf(
                            "z = " .. block.z,
                            block.x,
                            block.y,
                            block.w / valueScale.levelView,
                            "left",
                            0,
                            valueScale.levelView,
                            valueScale.levelView
                    )
                end
                if kblock == self.game.activeSpawn then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setLineWidth(block.borderW)
                    love.graphics.rectangle("line", block.x - self.step.w, block.y - self.step.h, block.w + 2 * self.step.w, block.h + 2 * self.step.h)
                    love.graphics.setLineWidth(self.step.w)
                end
                if block.entityType == "Breakable" then
                    love.graphics.setColor(1 - block.color[1], 1 - block.color[2], 1 - block.color[3])
                    love.graphics.draw(cracksPic, block.x, block.y, 0, block.w / cracksPic:getWidth(), block.h / cracksPic:getHeight())
                end
            end
        end
        love.graphics.setLineWidth(0.01)
        if self.h * self.scale / layout.h > 6.5 then
            love.graphics.setColor(1, 1, 1)
            for i = 0, math.max(layout.w, layout.h) do
                love.graphics.line(
                        0,
                        i * self.h / layout.h,
                        self.w,
                        i * self.h / layout.h
                )--horizontal

                love.graphics.line(
                        i * self.w / layout.w,
                        0,
                        i * self.w / layout.w,
                        self.h
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

function levelbox:getActiveMap()
    return self.game.maps[self.game.activeMap]
end

function levelbox:newBlock(type, map)
    if not inArray(type, arrayKeys(self.blockTypes)) then
        error("Type " .. type .. " doesn't exist!")
    end
    map = map or self.game.activeMap
    if map and
            between(0, cursor.x, screen:get("levelbox").w) and
            between(0, cursor.y, screen:get("levelbox").h) then
        local name = map .. "_" .. type .. self:getMap(map).blocksCount + 1
        self:getMap(map).blocks[name] = {
            x = (cursor.x - self.offsetX) / self.scale,
            y = (cursor.y - self.offsetY) / self.scale,
            z = 1,
            w = 50,
            h = 100,
            border = 10,
            borderW = 5,
            color = { colorPick.currentColor.r, colorPick.currentColor.g, colorPick.currentColor.b },
            grabbedX = 25,
            grabbedY = 50,
            value = "",
            type = type,
            entityType = ""
        }
        self.blockTypes[type].new(name, map)
        self:getMap(map).blocksCount = self:getMap(map).blocksCount + 1
        self.selectedBlock = name
        contextMenu:setActiveScreen("for" .. type)
    end
end

function levelbox:setType(category, innerType, block)
    block = block or self:getSelectedBlock()
    if block.entityType and button:exists("new" .. block.entityType) then
        button:get("new" .. block.entityType).color = button:get("new" .. block.entityType).colorUnclicked
    end
    block.category = category
    block.innerType = innerType
    block.entityType = contextMenu.screens["for" .. block.type].categories[category].types[innerType].sign
    button:get("new" .. block.entityType).color = button:get("new" .. block.entityType).colorClicked
end

function levelbox:newMap(sizeX, sizeY)
    if self:getMapView() then
        local name = "map" .. self.game.mapsCount + 1
        self.game.maps[name] = {
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
            value = "m" .. self.game.mapsCount + 1,
            type = "Map",
            blocks = {},
            spawns = {},
            targets = {},
            backgroundColor = { 1, 1, 1 },
            blocksCount = 0
        }
        self.game.mapsCount = self.game.mapsCount + 1
        self.selectedMap = name
    end
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

function levelbox:deleteblock(map)
    map = map or self.game.activeMap
    if self.selectedBlock then
        if self:getBlock(self.selectedBlock, map).type == "Spawn" then
            self:deletelink(self:getSpawn(self.selectedBlock).link)
            self:getMap(map).spawns[self.selectedBlock] = nil
        elseif self:getBlock(self.selectedBlock, map).type == "Portal" or self:getBlock(self.selectedBlock, map).type == "Checkpoint" then
            self:deletelink(self:getTarget(self.selectedBlock).link)
            self:getMap(map).targets[self.selectedBlock] = nil
        end
        self:getMap(map).blocks[self.selectedBlock] = nil
        self.selectedBlock = nil
        self.grabbedBlock = nil
        contextMenu:setActiveScreen()
    elseif self.selectedMap then
        for k, link in pairs(self.links) do
            if link.spawn.map == self.selectedMap or link.target.map == self.selectedMap then
                levelbox:deletelink(k)
            end
        end
        self.game.maps[self.selectedMap] = nil
        self.selectedMap = nil
        self.grabbedMap = nil
    end
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

function levelbox:getGrabbedBlock()
    return self:getBlock(self.grabbedBlock)
end

function levelbox:setBlockProperty(name, prop, val)
    local block = self:getBlock(name)
    block[prop] = val
    if block.type == "Spawn" then
        self:getSpawn(name)[prop] = val
    elseif self:getGrabbedBlock().type == "Portal" or self:getGrabbedBlock().type == "Checkpoint" then
        self:getTarget(name)[prop] = val
    end
end

function levelbox:getBlockBorderWidth(name)
    return (self:getBlock(name).border + self:getBlock(name).borderW / 2) / self.scale
end

function levelbox:blockFieldResizeE(name)
    return {
        x = self:getBlock(name).x + self:getBlock(name).w,
        y = self:getBlock(name).y - self:getBlockBorderWidth(name),
        w = self:getBlockBorderWidth(name),
        h = self:getBlock(name).h
    }
end

function levelbox:blockFieldResizeW(name)
    return {
        x = self:getGrabbedBlock().x - self:getBlockBorderWidth(name),
        y = self:getBlock(name).y - self:getBlockBorderWidth(name),
        w = self:getBlockBorderWidth(name),
        h = self:getBlock(name).h
    }
end

function levelbox:blockFieldResizeS(name)
    return {
        x = self:getGrabbedBlock().x - self:getBlockBorderWidth(name),
        y = self:getBlock(name).y + self:getBlock(name).h,
        w = self:getGrabbedBlock().w,
        h = self:getBlockBorderWidth(name)
    }
end

function levelbox:blockFieldResizeN(name)
    return {
        x = self:getGrabbedBlock().x - self:getBlockBorderWidth(name),
        y = self:getBlock(name).y - self:getBlockBorderWidth(name),
        w = self:getGrabbedBlock().w,
        h = self:getBlockBorderWidth(name)
    }
end

function levelbox:update()
    --love.mouse.setCursor(cursorSt)
    if love.keyboard.isDown("space") then
        self.grabbedBlock = nil
        self.grabbedMap = nil
        self.moving = true
    end
    if self.grabbedBlock then
        if cursor.inside(self:blockFieldResizeE(self.grabbedBlock)) and not self.grab or self.resize.E then
            love.mouse.setCursor(cursorWE)
            if love.mouse.isDown(1) then
                self.resize.E = true
                local dx = cursor.x - self:getGrabbedBlock().grabbedX
                self:getGrabbedBlock().grabbedX = cursor.x
                self:getGrabbedBlock().grabbedY = cursor.y
                self:setBlockProperty(self.grabbedBlock, "w", math.min(math.max(0, self:getGrabbedBlock().w + dx), self.w - self:getGrabbedBlock().x))
            else
                self.resize.E = false
            end
        elseif cursor.inside(self:blockFieldResizeW(self.grabbedBlock)) and not self.grab or self.resize.W then
            love.mouse.setCursor(cursorWE)
            if love.mouse.isDown(1) then
                self.resize.W = true
                local dx = cursor.x - self:getGrabbedBlock().grabbedX
                self:getGrabbedBlock().grabbedX = cursor.x
                self:getGrabbedBlock().grabbedY = cursor.y
                if self:getGrabbedBlock().x > 0 then
                    self:setBlockProperty(self.grabbedBlock, "w", math.min(math.max(0, self:getGrabbedBlock().w - dx), self.w - self:getGrabbedBlock().x))
                end
                if self:getGrabbedBlock().w > 0 then
                    self:setBlockProperty(self.grabbedBlock, "x", math.min(math.max(0, self:getGrabbedBlock().x + dx), self.w - self:getGrabbedBlock().w))
                end
            else
                self.resize.W = false
            end
        elseif cursor.inside(self:blockFieldResizeS(self.grabbedBlock)) and not self.grab or self.resize.S then
            love.mouse.setCursor(cursorNS)
            if love.mouse.isDown(1) then
                self.resize.S = true
                local dy = cursor.y - self:getGrabbedBlock().grabbedY
                self:getGrabbedBlock().grabbedX = cursor.x
                self:getGrabbedBlock().grabbedY = cursor.y
                self:setBlockProperty(self.grabbedBlock, "h", math.min(math.max(0, self:getGrabbedBlock().h + dy), self.h - self:getGrabbedBlock().y))
            else
                self.resize.S = false
            end
        elseif cursor.inside(self:blockFieldResizeN(self.grabbedBlock)) and not self.grab or self.resize.N then
            love.mouse.setCursor(cursorNS)
            if love.mouse.isDown(1) then
                self.resize.N = true
                local dy = cursor.y - self:getGrabbedBlock().grabbedY
                self:getGrabbedBlock().grabbedX = cursor.x
                self:getGrabbedBlock().grabbedY = cursor.y
                if self:getGrabbedBlock().y > 0 then
                    self:setBlockProperty(self.grabbedBlock, "h", math.min(math.max(0, self:getGrabbedBlock().h - dy), self.h - self:getGrabbedBlock().y))
                end
                if self:getGrabbedBlock().h > 0 then
                    self:setBlockProperty(self.grabbedBlock, "y", math.min(math.max(0, self:getGrabbedBlock().y + dy), self.h - self:getGrabbedBlock().h))
                end
            else
                self.resize.N = false
            end
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
            if love.mouse.isDown(1) then
                self:setGrab(true)
                local dx = cursor.x - self:getGrabbedBlock().grabbedX
                local dy = cursor.y - self:getGrabbedBlock().grabbedY
                self:setBlockProperty(self.grabbedBlock, "x", math.min(math.max(0, self:getGrabbedBlock().x + dx), self.w - self:getGrabbedBlock().w))
                self:setBlockProperty(self.grabbedBlock, "y", math.min(math.max(0, self:getGrabbedBlock().y + dy), self.h - self:getGrabbedBlock().h))
                local stuck = { x = false, y = false }
                local stuckWith = { w = 10 * self.step.w, h = 10 * self.step.h }
                for kblock, block in pairs(self:getActiveMap().blocks) do
                    if kblock ~= self.grabbedBlock then
                        if between(-stuckWith.w, block.x - (self:getGrabbedBlock().x + self:getGrabbedBlock().w), stuckWith.w) and
                                (block.y < self:getGrabbedBlock().y + self:getGrabbedBlock().h and self:getGrabbedBlock().y < block.y + block.h)
                        then
                            self:getGrabbedBlock().x = block.x - self:getGrabbedBlock().w
                            stuck.x = true
                        elseif between(-stuckWith.w, self:getGrabbedBlock().x - (block.x + block.w), stuckWith.w) and
                                (block.y < self:getGrabbedBlock().y + self:getGrabbedBlock().h and self:getGrabbedBlock().y < block.y + block.h)
                        then
                            self:getGrabbedBlock().x = block.x + block.w
                            stuck.x = true
                        elseif between(-stuckWith.h, block.y - (self:getGrabbedBlock().y + self:getGrabbedBlock().h), stuckWith.h) and
                                (block.x < self:getGrabbedBlock().x + self:getGrabbedBlock().w and self:getGrabbedBlock().x < block.x + block.w)
                        then
                            self:getGrabbedBlock().y = block.y - self:getGrabbedBlock().h
                            stuck.y = true
                        elseif between(-stuckWith.h, self:getGrabbedBlock().y - (block.y + block.h), stuckWith.h) and
                                (block.x < self:getGrabbedBlock().x + self:getGrabbedBlock().w and self:getGrabbedBlock().x < block.x + block.w)
                        then
                            self:getGrabbedBlock().y = block.y + block.h
                            stuck.y = true
                        end
                        --if stuck.x or stuck.y then break end
                    end
                end
                if not stuck.x then
                    self:getGrabbedBlock().grabbedX = cursor.x
                end
                if not stuck.y then
                    self:getGrabbedBlock().grabbedY = cursor.y
                end
            else
                self:setGrab(false)
            end
        end
        if not love.mouse.isDown(1) then
            self:setBlockProperty(self.grabbedBlock, "x", customRound(self:getSelectedBlock().x, self.w / layout.w))
            self:setBlockProperty(self.grabbedBlock, "y", customRound(self:getSelectedBlock().y, self.h / layout.h))
            self:setBlockProperty(self.grabbedBlock, "w", customRound(self:getSelectedBlock().w, self.w / layout.w))
            self:setBlockProperty(self.grabbedBlock, "h", customRound(self:getSelectedBlock().h, self.h / layout.h))
            self:getSelectedBlock().grabbedX = customRound(self:getSelectedBlock().grabbedX, self.w / layout.w)
            self:getSelectedBlock().grabbedY = customRound(self:getSelectedBlock().grabbedY, self.h / layout.h)
        end
    elseif self.grabbedMap then
        if cursor.x > self.game.maps[self.grabbedMap].x - self.game.maps[self.grabbedMap].border / self.scale - self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.x < self.game.maps[self.grabbedMap].x and
                cursor.y > self.game.maps[self.grabbedMap].y - self.game.maps[self.grabbedMap].border / self.scale - self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.y < self.game.maps[self.grabbedMap].y + self.game.maps[self.grabbedMap].border / self.scale + self.game.maps[self.grabbedMap].borderW / self.scale / 2 + self.game.maps[self.grabbedMap].h
                and not self.grab or self.resize.W then
            love.mouse.setCursor(cursorWE)
            if love.mouse.isDown(1) then
                self.resize.W = true
                local dx = cursor.x - self.game.maps[self.grabbedMap].grabbedX
                self.game.maps[self.grabbedMap].grabbedX = cursor.x
                self.game.maps[self.grabbedMap].grabbedY = cursor.y
                self.game.maps[self.grabbedMap].x = math.min(math.max(0, self.game.maps[self.grabbedMap].x + dx), self.w - self.game.maps[self.grabbedMap].w)
                self.game.maps[self.grabbedMap].w = math.min(math.max(0, self.game.maps[self.grabbedMap].w - dx), self.w - self.game.maps[self.grabbedMap].x)
            else
                self.resize.W = false
            end
        elseif cursor.x > self.game.maps[self.grabbedMap].x + self.game.maps[self.grabbedMap].w and
                cursor.x < self.game.maps[self.grabbedMap].x + self.game.maps[self.grabbedMap].w + self.game.maps[self.grabbedMap].border / self.scale + self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.y > self.game.maps[self.grabbedMap].y - self.game.maps[self.grabbedMap].border / self.scale - self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.y < self.game.maps[self.grabbedMap].y + self.game.maps[self.grabbedMap].border / self.scale + self.game.maps[self.grabbedMap].borderW / self.scale / 2 + self.game.maps[self.grabbedMap].h
                and not self.grab or self.resize.E then
            love.mouse.setCursor(cursorWE)
            if love.mouse.isDown(1) then
                self.resize.E = true
                local dx = cursor.x - self.game.maps[self.grabbedMap].grabbedX
                self.game.maps[self.grabbedMap].grabbedX = cursor.x
                self.game.maps[self.grabbedMap].grabbedY = cursor.y
                self.game.maps[self.grabbedMap].w = math.min(math.max(0, self.game.maps[self.grabbedMap].w + dx), self.w - self.game.maps[self.grabbedMap].x)
            else
                self.resize.E = false
            end
        elseif cursor.x > self.game.maps[self.grabbedMap].x - self.game.maps[self.grabbedMap].border / self.scale - self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.x < self.game.maps[self.grabbedMap].x + self.game.maps[self.grabbedMap].w + self.game.maps[self.grabbedMap].border / self.scale + self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.y > self.game.maps[self.grabbedMap].y - self.game.maps[self.grabbedMap].border / self.scale - self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.y < self.game.maps[self.grabbedMap].y
                and not self.grab or self.resize.N then
            love.mouse.setCursor(cursorNS)
            if love.mouse.isDown(1) then
                self.resize.N = true
                local dy = cursor.y - self.game.maps[self.grabbedMap].grabbedY
                self.game.maps[self.grabbedMap].grabbedX = cursor.x
                self.game.maps[self.grabbedMap].grabbedY = cursor.y
                self.game.maps[self.grabbedMap].y = math.min(math.max(0, self.game.maps[self.grabbedMap].y + dy), self.h - self.game.maps[self.grabbedMap].h)
                self.game.maps[self.grabbedMap].h = math.min(math.max(0, self.game.maps[self.grabbedMap].h - dy), self.h - self.game.maps[self.grabbedMap].y)
            else
                self.resize.N = false
            end
        elseif cursor.x > self.game.maps[self.grabbedMap].x - self.game.maps[self.grabbedMap].border / self.scale - self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.x < self.game.maps[self.grabbedMap].x + self.game.maps[self.grabbedMap].w + self.game.maps[self.grabbedMap].border / self.scale + self.game.maps[self.grabbedMap].borderW / self.scale / 2 and
                cursor.y > self.game.maps[self.grabbedMap].y + self.game.maps[self.grabbedMap].h and
                cursor.y < self.game.maps[self.grabbedMap].y + self.game.maps[self.grabbedMap].h + self.game.maps[self.grabbedMap].border / self.scale + self.game.maps[self.grabbedMap].borderW / self.scale / 2
                and not self.grab or self.resize.S then
            love.mouse.setCursor(cursorNS)
            if love.mouse.isDown(1) then
                self.resize.S = true
                local dy = cursor.y - self.game.maps[self.grabbedMap].grabbedY
                self.game.maps[self.grabbedMap].grabbedX = cursor.x
                self.game.maps[self.grabbedMap].grabbedY = cursor.y
                self.game.maps[self.grabbedMap].h = math.min(math.max(0, self.game.maps[self.grabbedMap].h + dy), self.h - self.game.maps[self.grabbedMap].y)
            else
                self.resize.S = false
            end
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
            if love.mouse.isDown(1) then
                self:setGrab(true)
                local dx = cursor.x - self.game.maps[self.grabbedMap].grabbedX
                local dy = cursor.y - self.game.maps[self.grabbedMap].grabbedY
                self.game.maps[self.grabbedMap].grabbedX = cursor.x
                self.game.maps[self.grabbedMap].grabbedY = cursor.y
                self.game.maps[self.grabbedMap].x = math.min(math.max(0, self.game.maps[self.grabbedMap].x + dx), self.w - self.game.maps[self.grabbedMap].w)
                self.game.maps[self.grabbedMap].y = math.min(math.max(0, self.game.maps[self.grabbedMap].y + dy), self.h - self.game.maps[self.grabbedMap].h)
            else
                self:setGrab(false)
            end
        end
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