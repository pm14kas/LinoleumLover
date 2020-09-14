function levelbox:loadHelpers()
    local dirs = {
        "levelbox",
    }
    for i = 1, #dirs, 1 do
        local files = love.filesystem.getDirectoryItems(dirs[i])
        for k, file in ipairs(files) do
            if love.filesystem.getInfo(dirs[i] .. "/" .. file).type == "file" then
                require(dirs[i] .. "/" .. file:sub(1, -5))
            end
        end
    end
end

function levelbox:loadGame()
    self.game = file_exists("mapForBuilder.linoleum") and json.decode(read_file("mapForBuilder.linoleum")) or
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
        }
end

function levelbox:loadMaps()
    for kmap, loadMap in pairs(self.game.maps) do
        local newMap = map:new(loadMap)
        newMap:setDefaults()
        if not newMap.name then newMap.name = kmap end
        self.state.maps[kmap] = newMap
        if not self.state.activeMap then
            self.state.activeMap = kmap
        end
        for kblock, loadBlock in pairs(loadMap.blocks) do
            self:loadBlock(kmap, kblock, loadBlock)
        end
    end
end

function levelbox:loadBlock(mapIndex, blockIndex, loadBlock)
    local newBlock = block:new(loadBlock)
    newBlock:convertType()
    newBlock:setDefaults()
    if not newBlock.name then newBlock.name = blockIndex end
    if not newBlock.map then newBlock.map = mapIndex end
    
    newBlock:align()
    self.state.maps[mapIndex].blocks[blockIndex] = newBlock
end

function levelbox:loadBasic()
    self.x = screen:get("levelbox").X
    self.y = screen:get("levelbox").Y
    self.offsetX = screen:get("levelbox").X
    self.offsetY = screen:get("levelbox").Y
    self.w = screen:get("levelbox").w
    self.h = screen:get("levelbox").h
    self.moving = false
    self.grabbedX = 25
    self.grabbedY = 50
    self.scale = 1
    self.scaleMin = 1
    self.scaleMax = 100
    self.scaleStep = 0.1
    self.scaleMult = 5
    self.grabbedBlock = nil
    self.grabbedMap = nil
    self.resize = {
        W = false,
        E = false,
        S = false,
        N = false,
    }
    self.grab = false
    self.linkMode = false
    self.UnlinkMode = false
    self.linkingSpawn = nil
    self.linkingTarget = nil
    self.mapView = {
        set = false,
        scale = 1,
        offset = { x = 0, y = 0 },
    }
    self.step = {
        w = self.w / layout.w,
        h = self.h / layout.h,
        mult = 1,
        max = 99
    }
end

function levelbox:loadState()
    self.state = {
        maps = {},
        activeSpawn = "",
        mapsCount = 0,
        linksCount = 0,
        activeMap = "map0",
        screenScale = { w = w / layout.w, h = h / layout.h }
    }
    self.state.linksCount = self.game.linksCount
    self.state.mapsCount = self.game.mapsCount
    self.state.activeMap = self.game.activeMap
    self.state.activeSpawn = self.game.activeSpawn
    self.state.selectedBlock = self.game.selectedBlock
    self.state.selectedMap = self.game.selectedMap
    self.state.highlightedBlock = self.game.highlightedBlock
end

function levelbox:loadLinks()
    self.links = file_exists("linksForBuilder.linoleum") and json.decode(read_file("linksForBuilder.linoleum")) or {}
    
    for klink, link in pairs(self.links) do
        local exists = false
        for kmap, map in pairs(self.state.maps) do
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
end

function levelbox:loadBlockTypes()
    self.blockTypes = {
        Block = blockType:new({
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.entityType = "Solid"
                block.saveTo = "blocks"
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].entityType = block.entityType
            end
        }),
        Spawn = blockType:new({
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
            select = function(name, map)
                local block = levelbox:getBlock(name, map)
                local buttonName = "newforSpawn_Active"
                if levelbox.state.activeSpawn == name then
                    button:get(buttonName).color = button:get(buttonName).colorClicked
                else
                    button:get(buttonName).color = button:get(buttonName).colorUnclicked
                end
            end,
            delete = function(name, map)
                levelbox:deletelink(levelbox:getSpawn(name).link)
                levelbox:getMap(map).spawns[name] = nil
            end,
        }),
        Portal = blockType:new({
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
            delete = function(name, map)
                levelbox:deletelink(levelbox:getTarget(name).link)
                levelbox:getMap(map).targets[name] = nil
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].spawn = levelbox:getMap(map).targets[name].spawn
            end
        }),
        Checkpoint = blockType:new({
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
            delete = function(name, map)
                levelbox:deletelink(levelbox:getTarget(name).link)
                levelbox:getMap(map).targets[name] = nil
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].spawn = levelbox:getMap(map).targets[name].spawn
            end
        }),
        Hazard = blockType:new({
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.color = { 1, 0, 0 }
                block.value = "H"
                block.saveTo = "hazards"
            end,
        }),
        AI = blockType:new({
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
        }),
        Item = blockType:new({
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
        }),
        Text = blockType:new({
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
        }),
        Button = blockType:new({
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.h = 50
                block.w = 50
                block.saveTo = "buttons"
                block.color = { 1, 1, 1 }
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].links = block.links
            end,
        }),
        Door = blockType:new({
            new = function(name, map)
                local block = levelbox:getBlock(name, map)
                block.entityType = contextMenu.screens["forDoor"].categories[1].types[2].sign
                block.saveTo = "doors"
                table.insert(levelbox:getMap(map).doors, name)
                contextMenu.screens.forButton:reload()
            end,
            delete = function(name, map)
                table.removeByValue(levelbox:getMap(map).doors, name)
                contextMenu.screens.forButton:reload()
            end,
            save = function(name, arrayToSave, map)
                local block = levelbox:getBlock(name, map)
                arrayToSave.maps[map][block.saveTo][name].entityType = block.entityType
            end,
        })
    }
end