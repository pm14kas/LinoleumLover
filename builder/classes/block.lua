require("classes.updatable")

block = updatable:new()

function block:setProperty(prop, val)
    updatable.setProperty(self, prop, val)
    if self.type == "Spawn" then
        local spawn = levelbox:getSpawn(self)
        if not spawn then
            spawn = levelbox.blockTypes.Spawn.new(self.name, self.map)
        end
        spawn[prop] = val
    elseif self.type == "Portal" or self.type == "Checkpoint" then
        local target = levelbox:getTarget(self)
        if not target then
            target = levelbox.blockTypes.Portal.new(self.name, self.map)
        end
        target[prop] = val
    end
end

function block:getContextMenuButtonName()
    return "newfor" .. self.type .. "_" .. self.entityType
end

function block:getContextMenuLinkName(link)
    return "newfor" .. self.type .. "_" .. link.name
end

function block:convertType()
    if self.type == "block" then self.type = "Block" end
    if self.type == "spawn" then self.type = "Spawn" end
    if self.type == "hazard" then self.type = "Hazard" end
    if self.type == "target" then self.type = "Portal" end
    if self.type == "checkpoint" then self.type = "Checkpoint" end
    if self.type == "text" then self.type = "Text" end
    if self.type == "AI" then self.type = "AI" end
    if self.type == "item" then self.type = "Item" end
end

function block:setDefaults()
    if not self.value then self.value = "" end
    if not self.category then self.category = 1 end
    if not self.innerType then self.innerType = 1 end
    if not self.z then self.z = 1 end
    if not self.w then self.w = 50 end
    if not self.h then self.h = 100 end
    if not self.border then self.border = 10 end
    if not self.borderW then self.borderW = 5 end
    if not self.grabbedX then self.grabbedX = 25 end
    if not self.grabbedY then self.grabbedY = 50 end
    if not self.value then self.value = "" end
    if not self.entityType then self.entityType = "" end
    if not self.innerType then self.innerType = 1 end
    if not self.category then self.category = 1 end
    if not self.links then self.links = {} end
    if self.type == "Block" then
        self.saveTo = "blocks"
        if not self.entityType then self.entityType = "Solid" end
    end
    if self.type == "Spawn" then
        self.saveTo = "spawns"
        if not self.entityType then self.entityType = "" end
    end
    if self.type == "Hazard" then
        self.saveTo = "hazards"
        if not self.entityType then self.entityType = "" end
    end
    if self.type == "Portal" then
        self.value = "P"
        self.saveTo = "portals"
        if not self.entityType then self.entityType = "" end
    end
    if self.type == "Checkpoint" then
        self.saveTo = "checkpoints"
        if not self.entityType then self.entityType = "" end
    end
    if self.type == "Text" then
        self.saveTo = "decorations"
        if not self.entityType then self.entityType = "" end
    end
    if self.type == "AI" then
        self.saveTo = "ai"
        if not self.entityType then self.entityType = "Enemy" end
    end
    if self.type == "Item" then
        self.saveTo = "items"
        if not self.entityType then self.entityType = "Money" end
    end
end

function block:draw()
    local valueScale = (50 / graphikFont:getHeight() / 3)
    if self.type == "Hazard" then
        love.graphics.setColor({1, math.sin(love.timer.getTime() * 6) * 0.5 + 0.5, 0.1});
    else
        love.graphics.setColor(self.color)
    end
    if self.type == "Text" then
        love.graphics.setFont(graphikFont)
        love.graphics.printf(
            self.value,
            self.x,
            self.y,
            math.max(self.w, love.graphics.getFont():getWidth(self.value)),
            "left",
            0,
            self.w / love.graphics.getFont():getWidth(self.value),
            self.h / love.graphics.getFont():getHeight()
        )
        if self.selected or self.highlighted then
            love.graphics.setLineWidth(self.borderW / levelbox.scale)
            love.graphics.rectangle("line", self.x - self.border / levelbox.scale, self.y - self.border / levelbox.scale,
                                    self.w + self.border / levelbox.scale * 2, self.h + self.border / levelbox.scale * 2)
            love.graphics.setLineWidth(1)
        end
    else
        if self.type == "Item" then
            love.graphics.draw(
                contextMenu.screens["forItem"].categories[self.category].types[self.innerType].picture,
                self.x,
                self.y,
                0,
                self.w / contextMenu.screens["forItem"].categories[self.category].types[self.innerType].picture:getWidth(),
                self.h / contextMenu.screens["forItem"].categories[self.category].types[self.innerType].picture:getHeight()
            )
        --elseif self.type == "Button" then
        --    love.graphics.draw(
        --        contextMenu.screens["forButton"].categories[self.category].types[self.innerType].picture,
        --        self.x,
        --        self.y,
        --        0,
        --        self.w / contextMenu.screens["forButton"].categories[self.category].types[self.innerType].picture:getWidth(),
        --        self.h / contextMenu.screens["forButton"].categories[self.category].types[self.innerType].picture:getHeight()
        --    )
        else
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
            
            love.graphics.setColor(0, 0, 0)
            love.graphics.setLineWidth(3 * levelbox.step.w)
            love.graphics.rectangle("line", self.x + 3 / 2 * levelbox.step.w, self.y + 3 / 2 * levelbox.step.h,
                                    self.w - 3 * levelbox.step.w,
                                    self.h - 3 * levelbox.step.h) --x, y += offset + linewidth / 2; w, h -= 2 * offset + linewidth
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(1 * levelbox.step.w)
            love.graphics.rectangle("line", self.x + (1 + 1 / 2) * levelbox.step.w, self.y + (1 + 1 / 2) * levelbox.step.h,
                                    self.w - 3 * levelbox.step.w, self.h - 3 * levelbox.step.h)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(graphikFont)
            love.graphics.printf(
                self.value,
                self.x,
                self.y,
                self.w / valueScale,
                "center",
                0,
                valueScale,
                valueScale
            )
        end
        if self.selected or self.highlighted then
            love.graphics.setColor(self.color)
            love.graphics.setLineWidth(self.borderW / levelbox.scale)
            love.graphics.rectangle("line", self.x - self.border / levelbox.scale, self.y - self.border / levelbox.scale,
                                    self.w + self.border / levelbox.scale * 2, self.h + self.border / levelbox.scale * 2)
            love.graphics.setLineWidth(levelbox.step.w)
            
            love.graphics.setColor(1 - self.color[1], 1 - self.color[2], 1 - self.color[3])
            love.graphics.setFont(graphikFont)
            love.graphics.printf(
                "z = " .. self.z,
                self.x,
                self.y,
                self.w / valueScale,
                "left",
                0,
                valueScale,
                valueScale
            )
        end
        if self.name == levelbox.state.activeSpawn then
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(self.borderW)
            love.graphics.rectangle("line", self.x - levelbox.step.w, self.y - levelbox.step.h, self.w + 2 * levelbox.step.w,
                                    self.h + 2 * levelbox.step.h)
            love.graphics.setLineWidth(levelbox.step.w)
        end
        if self.entityType == "Breakable" then
            love.graphics.setColor(1 - self.color[1], 1 - self.color[2], 1 - self.color[3])
            love.graphics.draw(cracksPic, self.x, self.y, 0, self.w / cracksPic:getWidth(),
                               self.h / cracksPic:getHeight())
        end
    end
end

function block:setType(category, innerType)
    if self.entityType and button:exists(self:getContextMenuButtonName()) then
        button:get(self:getContextMenuButtonName()).color = button:get(self:getContextMenuButtonName()).colorUnclicked
    end
    self.category = category
    self.innerType = innerType
    self.entityType = contextMenu.screens["for" .. self.type].categories[category].types[innerType].sign
    button:get(self:getContextMenuButtonName()).color = button:get(self:getContextMenuButtonName()).colorClicked
end

function block:delete()
    levelbox.grabbedBlock = nil
    self:unselect()
    contextMenu:setActiveScreen()
    for key, link in pairs(self.links) do
        if link.name and link.map and levelbox:blockExists(link.name, link.map) then
            levelbox:getBlock(link.name, link.map).links[self.name .. self.map] = nil
        end
    end
    levelbox:getActiveMap().blocks[self.name] = nil
end

function block:unselect()
    updatable.unselect(self)
    levelbox.state.selectedBlock = nil
end

function block:move(dx, dy)
    updatable.move(self, dx, dy)
    self:stick()
end

function block:stick()
    local stuck = { x = false, y = false }
    local stuckWith = { w = 10 * levelbox.step.w, h = 10 * levelbox.step.h }
    for kblock, otherBlock in pairs(levelbox:getActiveMap().blocks) do
        if kblock ~= self.name then
            if between(-stuckWith.w, otherBlock.x - (self.x + self.w), stuckWith.w) and
                (otherBlock.y < self.y + self.h and self.y < otherBlock.y + otherBlock.h)
            then
                self.x = otherBlock.x - self.w
                stuck.x = true
            elseif between(-stuckWith.w, self.x - (otherBlock.x + otherBlock.w), stuckWith.w) and
                (otherBlock.y < self.y + self.h and self.y < otherBlock.y + otherBlock.h)
            then
                self.x = otherBlock.x + otherBlock.w
                stuck.x = true
            elseif between(-stuckWith.h, otherBlock.y - (self.y + self.h), stuckWith.h) and
                (otherBlock.x < self.x + self.w and self.x < otherBlock.x + otherBlock.w)
            then
                self.y = otherBlock.y - self.h
                stuck.y = true
            elseif between(-stuckWith.h, self.y - (otherBlock.y + otherBlock.h), stuckWith.h) and
                (otherBlock.x < self.x + self.w and self.x < otherBlock.x + otherBlock.w)
            then
                self.y = otherBlock.y + otherBlock.h
                stuck.y = true
            end
        end
    end
    if not stuck.x then
        self.grabbedX = cursor.x
    end
    if not stuck.y then
        self.grabbedY = cursor.y
    end
end