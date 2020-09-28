timer = {};

function timer:new(duration)
    duration = duration or 1000;
    local data = {
        duration = duration,
        startTime = love.timer.getTime() * 1000,
        triggered = false,
        active = false,
    }

    setmetatable(data, self);
    self.__index = self;

    return data;
end

function timer:start()
    self.active = true;
    self.startTime = love.timer.getTime() * 1000;
    self.triggered = false;

    return self;
end

function timer:stop()
    self.active = false;
    self.startTime = love.timer.getTime() * 1000;
    self.triggered = false;

    return self;
end

function timer:update()
    if self.active then
        if not self.triggered and love.timer.getTime() * 1000 > self.startTime + self.duration then
            self.triggered = true;
        end
    else
        self.startTime = love.timer.getTime() * 1000;
    end

    return self;
end

function timer:isTriggered()
    return self.active and self.triggered;
end

function timer:isNotTriggered()
    return self.active and not self.triggered;
end

function timer:isActive()
    return self.active;
end