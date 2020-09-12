local enet = require "enet"
local host = nil;
local server = nil;
local isServer = false;
local isMultiplayerActive = true;
local bandwidthLimiter = 0

-- 0.35 is purely empirical
local multiplayerTimeoutMultiplier = 0.35;

if isMultiplayerActive then
    if isServer then
        host = enet.host_create("*:27015", 1);
    else
        host = enet.host_create()
        server = host:connect(ENVIRONMENT_TRAVERSAL_IP .. ":27015")
    end
end

network = {
    x = 0,
    y = 0,
    lastState = {
        x = 0,
        y = 0,
    },
    width = layout.getX(50),
    height = layout.getY(100),
    currentMap = nil,
    direction = 1,
    isLeftWallClimb = false,
    isRightWallClimb = false,
    isDashing = false,
    bandwidthLimiter = 0,
    bulletList = {},
    bulletWidth = layout.getX(10),
    bulletHeight = layout.getY(5),
}

function network:reset()
    self.lastState = {
        x = 0,
        y = 0,
    };
    self.x = 0;
    self.y = 0;
    self.currentMap = nil;
end

function network:extrapolate()
    local shiftX = self.x - self.lastState.x;
    local shiftY = self.y - self.lastState.y;

    self.lastState.x = self.x;
    self.lastState.y = self.y;

    self.x = self.x + shiftX * 0.2;
    self.y = self.y + shiftY * 0.2;
end

function network:update(dt)
    if not isMultiplayerActive then
        return;
    end

    if not (player.body:getX() and player.body:getY() and level.activeMap) then
        return;
    end

    --self.bandwidthLimiter = self.bandwidthLimiter + 1;

    --if self.bandwidthLimiter < bandwidthLimiter then
     --   return;
   -- else
   --     self.bandwidthLimiter = 0;
   -- end

    local event = host:service(multiplayerTimeoutMultiplier / dt)
    if event then
        if event.type == "receive" then
            self:parseData(event.data)
            --network:extrapolate();

            if isServer then
                event.peer:send(self:buildData())
            end
        elseif event.type == "connect" then
            self:reset();
            event.peer:send(self:buildData())
        elseif event.type == "disconnect" then
            self:reset();
        end
    else
        network:extrapolate();
    end

    if not isServer then
        server:send(self:buildData())
    end
end



function network:buildData()
    local data = {
        player = {
            x = layout.invertX(player.body:getX()),
            y = layout.invertY(player.body:getY()),
            direction = player.direction,
            isLeftWallClimb = player.isLeftWallClimb,
            isRightWallClimb = player.isRightWallClimb,
            isDashing = player.isLeftDash or player.isRightDash,
            currentMap = level.activeMap,
        },
        bulletList = {},
    };

    for key, bullet in ipairs(player.bulletList) do
        if (not bullet.body:isDestroyed()) then
            local bulletBlock = {
                x = bullet.body:getX(),
                y = bullet.body:getY(),
            }
            table.insert(data.bulletList, bulletBlock);
        end
    end

    return json.encode(data);
end

function network:parseData(rawData)
    local data =  json.decode(rawData);

    self.lastState.x = self.x;
    self.lastState.y = self.y;

    self.x = layout.getX(data.player.x);
    self.y = layout.getY(data.player.y);
    self.currentMap = data.player.currentMap;

    self.direction = data.player.direction;
    self.isLeftWallClimb = data.player.isLeftWallClimb;
    self.isRightWallClimb = data.player.isRightWallClimb;
    self.isDashing = data.player.isDashing;

    self.bulletList = data.bulletList;
end



function network:draw()
    if not (level.activeMap and self.currentMap) then
        return;
    end

    if (level.activeMap == self.currentMap) then
        if (self.isDashing or self.isDashing) then
            love.graphics.setColor(1, 1, 1);
        else
            love.graphics.setColor(0.2, 0.2, 1);
        end

        love.graphics.rectangle("fill", self.x - self.width * 0.5, self.y - self.height * 0.5, self.width, self.height)
        if (self.isLeftWallClimb) then
            love.graphics.rectangle("fill", self.x, self.y - self.height * 0.2, self.width, self.height * 0.3);
        elseif (self.isRightWallClimb) then
            love.graphics.rectangle("fill", self.x, self.y - self.height * 0.2, -self.width, self.height * 0.3);
        end

        love.graphics.setColor(1, 1, 0);
        if self.direction == player.directionEnum.left then
            love.graphics.rectangle("fill", self.x - self.width * 0.5, self.y - self.height * 0.5, self.width * 0.1, self.height * 0.3);
        elseif self.direction == player.directionEnum.right then
            love.graphics.rectangle("fill", self.x + self.width * 0.4, self.y - self.height * 0.5, self.width * 0.1, self.height * 0.3);
        end

        love.graphics.setColor(0.1, 0.1, 0.1);
        for key, bullet in ipairs(self.bulletList) do
            love.graphics.rectangle("fill", bullet.x - self.bulletWidth * 0.5, bullet.y - self.bulletHeight * 0.5, self.bulletWidth, self.bulletHeight)
        end
    end
end
