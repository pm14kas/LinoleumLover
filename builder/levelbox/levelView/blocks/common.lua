function levelbox:getBlock(block, map)
    map = map or self.game.activeMap
    return self:getMap(map).blocks[block]
end

function levelbox:getSelectedBlock()
    return self:getBlock(self.selectedBlock)
end

function levelbox:selectBlock(block)
    if self.selectedBlock and button:exists("new" .. self:getSelectedBlock().entityType) then
        button:get("new" .. self:getSelectedBlock().entityType).color = button:get("new" .. self:getSelectedBlock().entityType).colorUnclicked
    end
    self.selectedBlock = block
    if block and button:exists("new" .. self:getSelectedBlock().entityType) then
        button:get("new" .. self:getSelectedBlock().entityType).color = button:get("new" .. self:getSelectedBlock().entityType).colorClicked
    end
end

function levelbox:drawBlock(name)
    block = self:getBlock(name)
    local valueScale = (50 / graphikFont:getHeight() / 3)
    love.graphics.setColor(block.color)
    if block.type == "Text" then
        love.graphics.setFont(graphikFont)
        love.graphics.printf(
            block.value,
            block.x,
            block.y,
            math.max(block.w, love.graphics.getFont():getWidth(block.value)),
            "left",
            0,
            block.w / love.graphics.getFont():getWidth(block.value),
            block.h / love.graphics.getFont():getHeight()
        )
        if name == self.selectedBlock then
            love.graphics.setLineWidth(block.borderW / self.scale)
            love.graphics.rectangle("line", block.x - block.border / self.scale, block.y - block.border / self.scale,
                                    block.w + block.border / self.scale * 2, block.h + block.border / self.scale * 2)
            love.graphics.setLineWidth(1)
        end
    else
        if block.type == "Item" then
            love.graphics.draw(
                contextMenu.screens["forItem"].categories[block.category].types[block.innerType].picture,
                block.x,
                block.y,
                0,
                block.w / contextMenu.screens["forItem"].categories[block.category].types[block.innerType].picture:getWidth(),
                block.h / contextMenu.screens["forItem"].categories[block.category].types[block.innerType].picture:getHeight()
            )
        elseif block.type == "Button" then
            love.graphics.draw(
                contextMenu.screens["forButton"].categories[block.category].types[block.innerType].picture,
                block.x,
                block.y,
                0,
                block.w / contextMenu.screens["forButton"].categories[block.category].types[block.innerType].picture:getWidth(),
                block.h / contextMenu.screens["forButton"].categories[block.category].types[block.innerType].picture:getHeight()
            )
        else
            love.graphics.rectangle("fill", block.x, block.y, block.w, block.h)
            
            love.graphics.setColor(0, 0, 0)
            love.graphics.setLineWidth(3 * self.step.w)
            love.graphics.rectangle("line", block.x + 3 / 2 * self.step.w, block.y + 3 / 2 * self.step.h,
                                    block.w - 3 * self.step.w,
                                    block.h - 3 * self.step.h) --x, y += offset + linewidth / 2; w, h -= 2 * offset + linewidth
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(1 * self.step.w)
            love.graphics.rectangle("line", block.x + (1 + 1 / 2) * self.step.w, block.y + (1 + 1 / 2) * self.step.h,
                                    block.w - 3 * self.step.w, block.h - 3 * self.step.h)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(graphikFont)
            love.graphics.printf(
                block.value,
                block.x,
                block.y,
                block.w / valueScale,
                "center",
                0,
                valueScale,
                valueScale
            )
        end
        if name == self.selectedBlock then
            love.graphics.setColor(block.color)
            love.graphics.setLineWidth(block.borderW / self.scale)
            love.graphics.rectangle("line", block.x - block.border / self.scale, block.y - block.border / self.scale,
                                    block.w + block.border / self.scale * 2, block.h + block.border / self.scale * 2)
            love.graphics.setLineWidth(self.step.w)
            
            love.graphics.setColor(1 - block.color[1], 1 - block.color[2], 1 - block.color[3])
            love.graphics.setFont(graphikFont)
            love.graphics.printf(
                "z = " .. block.z,
                block.x,
                block.y,
                block.w / valueScale,
                "left",
                0,
                valueScale,
                valueScale
            )
        end
        if name == self.game.activeSpawn then
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(block.borderW)
            love.graphics.rectangle("line", block.x - self.step.w, block.y - self.step.h, block.w + 2 * self.step.w,
                                    block.h + 2 * self.step.h)
            love.graphics.setLineWidth(self.step.w)
        end
        if block.entityType == "Breakable" then
            love.graphics.setColor(1 - block.color[1], 1 - block.color[2], 1 - block.color[3])
            love.graphics.draw(cracksPic, block.x, block.y, 0, block.w / cracksPic:getWidth(),
                               block.h / cracksPic:getHeight())
        end
    end
end

function levelbox:newBlock(type, map)
    if not inArray(type, arrayKeys(self.blockTypes)) then
        error("Type " .. type .. " doesn't exist!")
    end
    map = map or self.game.activeMap
    if map and
        between(0, cursor.x, screen:get("levelbox").w) and
        between(0, cursor.y, screen:get("levelbox").h) then
        local name = map .. "_" .. type .. self:getMap(map).blocksCount + 1
        self:getMap(map).blocks[name] = {
            x = (cursor.x - self.offsetX) / self.scale,
            y = (cursor.y - self.offsetY) / self.scale,
            z = 1,
            w = 50,
            h = 100,
            border = 10,
            borderW = 5,
            color = { colorPick.currentColor.r, colorPick.currentColor.g, colorPick.currentColor.b },
            grabbedX = 25,
            grabbedY = 50,
            value = "",
            type = type,
            entityType = "",
            innerType = 1,
            category = 1,
            name = name,
            updatableType = "block"
        }
        self.blockTypes[type].new(name, map)
        self:getMap(map).blocksCount = self:getMap(map).blocksCount + 1
        self.selectedBlock = name
        self.grabbedBlock = name
        contextMenu:setActiveScreen("for" .. type)
    end
end

function levelbox:setType(category, innerType, block)
    block = block or self:getSelectedBlock()
    if block.entityType and button:exists("new" .. block.entityType) then
        button:get("new" .. block.entityType).color = button:get("new" .. block.entityType).colorUnclicked
    end
    block.category = category
    block.innerType = innerType
    block.entityType = contextMenu.screens["for" .. block.type].categories[category].types[innerType].sign
    button:get("new" .. block.entityType).color = button:get("new" .. block.entityType).colorClicked
end

function levelbox:deleteblock(map)
    map = map or self.game.activeMap
    if self.selectedBlock then
        if self:getBlock(self.selectedBlock, map).type == "Spawn" then
            self:deletelink(self:getSpawn(self.selectedBlock).link)
            self:getMap(map).spawns[self.selectedBlock] = nil
        elseif self:getBlock(self.selectedBlock, map).type == "Portal" or self:getBlock(self.selectedBlock,
                                                                                        map).type == "Checkpoint" then
            self:deletelink(self:getTarget(self.selectedBlock).link)
            self:getMap(map).targets[self.selectedBlock] = nil
        end
        self:getMap(map).blocks[self.selectedBlock] = nil
        self.selectedBlock = nil
        self.grabbedBlock = nil
        contextMenu:setActiveScreen()
    elseif self.selectedMap then
        for k, link in pairs(self.links) do
            if link.spawn.map == self.selectedMap or link.target.map == self.selectedMap then
                levelbox:deletelink(k)
            end
        end
        self.game.maps[self.selectedMap] = nil
        self.selectedMap = nil
        self.grabbedMap = nil
    end
end

function levelbox:getGrabbedBlock()
    return self:getBlock(self.grabbedBlock)
end

function levelbox:setBlockProperty(name, prop, val)
    local block = self:getBlock(name)
    block[prop] = val
    if block.type == "Spawn" then
        self:getSpawn(name)[prop] = val
    elseif block.type == "Portal" or block.type == "Checkpoint" then
        self:getTarget(name)[prop] = val
    end
end