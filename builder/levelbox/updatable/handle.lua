function levelbox:getUpdatable(name, type)
    local type = type or "block"
    if type == "block" then
        return self:getBlock(name)
    elseif type == "map" then
        return self:getMap(name)
    else
        error("Unknown type of updatable: " .. type)
    end
end

function levelbox:getUpdatableBorderWidth(updatable)
    return (updatable.border + updatable.borderW / 2) / self.scale
end

function levelbox:updatableFieldResizeE(updatable)
    return {
        x = updatable.x + updatable.w,
        y = updatable.y - self:getUpdatableBorderWidth(updatable),
        w = self:getUpdatableBorderWidth(updatable),
        h = updatable.h
    }
end

function levelbox:updatableFieldResizeW(updatable)
    return {
        x = updatable.x - self:getUpdatableBorderWidth(updatable),
        y = updatable.y - self:getUpdatableBorderWidth(updatable),
        w = self:getUpdatableBorderWidth(updatable),
        h = updatable.h
    }
end

function levelbox:updatableFieldResizeS(updatable)
    return {
        x = updatable.x - self:getUpdatableBorderWidth(updatable),
        y = updatable.y + updatable.h,
        w = updatable.w,
        h = self:getUpdatableBorderWidth(updatable)
    }
end

function levelbox:updatableFieldResizeN(updatable)
    return {
        x = updatable.x - self:getUpdatableBorderWidth(updatable),
        y = updatable.y - self:getUpdatableBorderWidth(updatable),
        w = updatable.w,
        h = self:getUpdatableBorderWidth(updatable)
    }
end

function levelbox:setUpdatableProperty(updatable, prop, val)
    updatable[prop] = val
    if updatable.updatableType == "block" then
        if updatable.type == "Spawn" then
            self:getSpawn(updatable.name)[prop] = val
        elseif updatable.type == "Portal" or updatable.type == "Checkpoint" then
            self:getTarget(updatable.name)[prop] = val
        end
    end
end