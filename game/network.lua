local enet = require "enet"
local host = nil;
local server = nil;
local isServer = true;

if isServer then
    host = enet.host_create("*:27015", 1);
else
    host = enet.host_create()
    server = host:connect("127.0.0.1:27015")
end

network = {
    x = 0,
    y = 0,
    width = layout.getX(50),
    height = layout.getY(100),
    currentMap = nil,
    direction = 1,
    isLeftWallClimb = false,
    isRightWallClimb = false,
    isDashing = false,
}

function network:update(dt)
    if not (player.body:getX() and player.body:getY() and level.activeMap and false) then
        return;
    end

    local event = host:service(1 / dt)
    while event do
        if event.type == "receive" then
            cmd, params = event.data:match("^(%S*) (.*)")
            if cmd == 'move' then
                self:parseData(params)

                if isServer then
                    event.peer:send(self:buildData())
                end
            else
                print("unrecognised command:", cmd)
            end
        elseif event.type == "connect" then
            self.x = 0;
            self.y = 0;
            self.currentMap = nil;
            event.peer:send(self:buildData())
        elseif event.type == "disconnect" then
            self.x = 0;
            self.y = 0;
            self.currentMap = nil;
        end
        event = host:service()
    end

    if not isServer then
        server:send(self:buildData())
    end
end

function network:buildData()
    playerX = layout.invertX(player.body:getX());
    playerY = layout.invertX(player.body:getY());
    direction = player.direction;
    isLeftWallClimb = player.isLeftWallClimb;
    isRightWallClimb = player.isRightWallClimb;
    isDashing = player.isLeftDash or player.isRightDash;

    local dg = string.format(
        "%s %f %f %d %s %s %s %s",
        'move',
        playerX,
        playerY,
        direction,
        tern(isLeftWallClimb, "t", "f"),
        tern(isRightWallClimb, "t", "f"),
        tern(isDashing, "t", "f"),
        level.activeMap
    );

    return dg;
end

function network:parseData(data)
    local playerX, playerY, direction, isLeftWallClimb, isRightWallClimb, isDashing, currentMap = parms:match(
        "^(%-?[%d.e]*) (%-?[%d.e]*) (%d) ([t,f]) ([t,f]) ([t,f]) ([t,f]) (.*)$"
    );

    playerX, playerY = tonumber(x), tonumber(y)
    direction = tonumber(direction)
    self.x = layout.getX(x)
    self.y = layout.getY(y)
    self.currentMap = currentMap

    self.direction = direction;
    self.isLeftWallClimb = (isLeftWallClimb == "t");
    self.isRightWallClimb = (isRightWallClimb == "t");
    self.isDashing = (isDashing == "t");
end

function network:draw()
    if not (level.activeMap and self.currentMap) then
        return;
    end

    if (level.activeMap == self.currentMap) then
        love.graphics.setColor(0.2, 0.2, 1);
        love.graphics.rectangle("fill", self.x - self.width * 0.5, self.y-self.height * 0.5, self.width, self.height)
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
    end
end