function levelbox:getBlock(block, map)
    map = map or self.state.activeMap
    return self:getMap(map).blocks[block]
end

function levelbox:getSelectedBlock()
    return self:getBlock(self.state.selectedBlock)
end

function levelbox:selectBlock(block)
    if self.state.selectedBlock then
        if button:exists(self:getSelectedBlock():getContextMenuButtonName()) then
            button:get(self:getSelectedBlock():getContextMenuButtonName()).color = button:get(self:getSelectedBlock():getContextMenuButtonName()).colorUnclicked
        end
        self:getSelectedBlock():unselect()
    end
    self.state.selectedBlock = block
    if block then
        self:getBlock(block):select()
        if button:exists(self:getSelectedBlock():getContextMenuButtonName()) then
            button:get(self:getSelectedBlock():getContextMenuButtonName()).color = button:get(self:getSelectedBlock():getContextMenuButtonName()).colorClicked
        end
    end
end

function levelbox:newBlock(type, map)
    if not inArray(type, arrayKeys(self.blockTypes)) then
        error("Type " .. type .. " doesn't exist!")
    end
    map = map or self.state.activeMap
    if map and
        between(0, cursor.x, screen:get("levelbox").w) and
        between(0, cursor.y, screen:get("levelbox").h) then
        local name = map .. "_" .. type .. self:getMap(map).blocksCount + 1
        local newBlock = block:new({
            x = (cursor.x - self.offsetX) / self.scale,
            y = (cursor.y - self.offsetY) / self.scale,
            color = { colorPick.currentColor.r, colorPick.currentColor.g, colorPick.currentColor.b },
            type = type,
            name = name,
        })
        newBlock:setDefaults()
        self:getMap(map).blocks[name] = newBlock
        self.blockTypes[type].new(name, map)
        self:getMap(map).blocksCount = self:getMap(map).blocksCount + 1
        self:selectBlock(name)
        self.grabbedBlock = name
        contextMenu:setActiveScreen("for" .. type)
    end
end

function levelbox:deleteblock()
    if self.state.selectedBlock then
        self:getSelectedBlock():delete()
    elseif self.state.selectedMap then
        self:getSelectedMap():delete()
    end
end

function levelbox:getGrabbedBlock()
    return self:getBlock(self.grabbedBlock)
end