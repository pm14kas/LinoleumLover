local enet = require "enet"
local host = nil;
local server = nil;
local isServer = ENVIRONMENT_DEFAULT_NETWORK_ROLE == 'server';
local isMultiplayerActive = true;
local isNatTraversalActive = false;
local bandwidthLimiter = 0

-- 0.35 is purely empirical
local multiplayerTimeoutMultiplier = 0.35;

if isMultiplayerActive then
    host = enet.host_create("*:" .. ENVIRONMENT_TRAVERSAL_PORT, 4)
end

if isMultiplayerActive and isNatTraversalActive then
    server = host:connect(ENVIRONMENT_TRAVERSAL_IP .. ":27015");

    local event = host:service(5000);
    if event then
        if event.type == "connect" then
            local traversalData = {
                messageType = 'register',
                type = tern(isServer, 'host', 'client'),
                secret = ENVIRONMENT_TRAVERSAL_SECRET_PHRASE,
            };
            server:send(json.encode(traversalData));

            event = host:service(5000);
            if event and event.type == 'receive' then
                data = json.decode(event.data);
                if data.result then
                    if not isServer then
                        traversalData = {
                            messageType = 'getHost',
                            secret = ENVIRONMENT_TRAVERSAL_SECRET_PHRASE,
                        };
                        server:send(json.encode(traversalData));

                        event = host:service(10000);
                        if event and event.type == 'receive' then
                            data = json.decode(event.data);
                            if data.result then
                                event.peer:reset();
                                print('i am client');
                                print(event.data);
                                server = host:connect(data.address);
                                server:send('test');

                                event = host:service(10000);
                                if event and event.type == 'receive' then
                                    print(event.data);
                                end
                            end
                        end
                    else
                        event = host:service(30000);
                        if event and event.type == 'receive' then
                            data = json.decode(event.data);
                            if data.result then
                                event.peer:reset();
                                print('i am server');
                                print(event.data);
                                server = host:connect(data.address);
                                server:send('test');

                                event = host:service(10000);
                                if event and event.type == 'receive' then
                                    print(event.data);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
elseif isMultiplayerActive then
    if not isServer then
        server = host:connect(ENVIRONMENT_TRAVERSAL_IP .. ":" .. ENVIRONMENT_TRAVERSAL_PORT);
    end
end

network = {};

function network:new()
    self.x = 0;
    self.y = 0;
    self.lastState = {
        x = 0,
        y = 0,
    };
    self.width = layout.getX(50);
    self.height = layout.getY(100);
    self.currentMap = nil;
    self.direction = 1;
    self.isLeftWallClimb = false;
    self.isRightWallClimb = false;
    self.isDashing = false;
    self.bandwidthLimiter = 0;
    self.bulletList = {};
    self.bulletWidth = layout.getX(10);
    self.bulletHeight = layout.getY(5);

    self.body = love.physics.newBody(world, self.x, self.y, "dynamic");
    self.body:setFixedRotation(true);
    self.shape = love.physics.newRectangleShape(self.width, self.height);
    self.fixture = love.physics.newFixture(self.body, self.shape);
    self.fixture:setUserData("network");
    self.fixture:setSensor(true);
end


function network:reset()
    self.lastState = {
        x = 0,
        y = 0,
    };
    self.x = 0;
    self.y = 0;
    self.currentMap = nil;
    self.body:setX(0);
    self.body:setY(0);
end

function network:extrapolate()
    --[[local shiftX = self.x - self.lastState.x;
    local shiftY = self.y - self.lastState.y;

    self.lastState.x = self.x;
    self.lastState.y = self.y;

    self.x = self.x + shiftX * 0.2;
    self.y = self.y + shiftY * 0.2;]]
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
    while event do
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

        event = host:service()
    end

    if not isServer then
        server:send(self:buildData())
    end

    --[[for k, v in pairs(level.doors) do
        v.networkState = false;
        v.fixture:setSensor(false);
    end

    for buttonIndex, button in pairs(level.buttons) do
        if self.body:isTouching(button.body) then
            print('sas');
            for linkIndex, linkValue in pairs(button.links) do
                if level.doors[linkValue.name] then
                    level.doors[linkValue.name].networkState = true
                    level.doors[linkValue.name].fixture:setSensor(true);
                end
            end
        end
    end
    ]]
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
    local data = json.decode(rawData);

    if not data.player then
        return;
    end

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

    self.body:setX(self.x);
    self.body:setY(self.y);
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
