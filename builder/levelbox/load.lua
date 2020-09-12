
function levelbox:loadHelpers()
    local dirs = {
        "levelbox",
        "levelbox/updatable",
        "levelbox/levelView",
        "levelbox/levelView/blocks",
        "levelbox/mapView",
        "levelbox/mapView/maps",
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
    self.selectedBlock = nil
    self.grabbedMap = nil
    self.selectedMap = nil
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
end

function levelbox:loadLinks()
    self.links = file_exists("linksForBuilder.linoleum") and json.decode(read_file("linksForBuilder.linoleum")) or {}
end