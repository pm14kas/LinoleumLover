function levelbox:getBlock(block, map)
    map = map or self.state.activeMap
    if not levelbox:blockExists(block, map) then
        error("block ".. block .. " in map " .. map .. " doesn't exist")
    end
    return self:getMap(map).blocks[block]
end

function levelbox:blockExists(name, map)
    return self:getMap(map).blocks[name]
end

function levelbox:getSelectedBlock(map)
    map = map or self.state.activeMap
    return self:getBlock(self.state.selectedBlock, map)
end

function levelbox:selectBlock(block)
    if self.state.selectedBlock then
        if button:exists(self:getSelectedBlock():getContextMenuButtonName()) then
            button:get(self:getSelectedBlock():getContextMenuButtonName()).color = button:get(self:getSelectedBlock():getContextMenuButtonName()).colorUnclicked
        end
        for index, link in ipairs(self:getSelectedBlock().links) do
            if button:exists(self:getSelectedBlock():getContextMenuLinkName(link)) then
                local triggerButton = button:get(self:getSelectedBlock():getContextMenuLinkName(link))
                triggerButton.color = triggerButton.colorUnclicked
            end
        end
        self:getSelectedBlock():unselect()
    end
    self.state.selectedBlock = block
    if block then
        self:getSelectedBlock():select()
        if button:exists(self:getSelectedBlock():getContextMenuButtonName()) then
            button:get(self:getSelectedBlock():getContextMenuButtonName()).color = button:get(self:getSelectedBlock():getContextMenuButtonName()).colorClicked
        end
        for index, link in ipairs(self:getSelectedBlock().links) do
            if button:exists("newfor" .. self:getSelectedBlock().type .. "_" .. link) then
                local triggerButton = button:get("newfor" .. self:getSelectedBlock().type .. "_" .. link)
                triggerButton.color = triggerButton.colorClicked
            end
        end
    end
end

function levelbox:getGrabbedBlock(map)
    map = map or self.state.activeMap
    return self:getBlock(self.grabbedBlock, map)
end

function levelbox:getHighlightedBlock(map)
    map = map or self.state.activeMap
    return self:getBlock(self.state.highlightedBlock, map)
end

function levelbox:highlightBlock(block, map)
    if map ~= nil and map ~= self.state.activeMap then
        return
    end
    if self.state.highlightedBlock then
        self:getHighlightedBlock(map):unhighlight()
    end
    self.state.highlightedBlock = block
    if block then
        self:getHighlightedBlock(map):highlight()
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
            map = map,
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
        local name = self:getSelectedBlock().name
        local map = self:getSelectedBlock().map
        local type = self:getSelectedBlock().type
        self:getSelectedBlock():delete()
        self.blockTypes[type].delete(name, map)
    elseif self.state.selectedMap then
        self:getSelectedMap():delete()
    end
end