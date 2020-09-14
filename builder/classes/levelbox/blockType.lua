blockType = {
    new = function(name, map) end,
    delete = function(name, map) end,
    select = function(name, map) end,
    save = function(name, arrayToSave, map) end,
}

function blockType:new(data)
    data = data or {}
    setmetatable(data, self)
    self.__index = self
    return data
end