require("updatable")

block = updatable:new()

function block:setProperty(prop, val)
    updatable.setProperty(self, prop, val)
    if self.type == "Spawn" then
        self:getSpawn(updatable.name)[prop] = val
    elseif self.type == "Portal" or self.type == "Checkpoint" then
        self:getTarget(self.name)[prop] = val
    end
end

--function block:get(block, map)
--    map = map or self.game.activeMap
--    return self:getMap(map).blocks[block]
--end

--function block:getSelectedBlock()
--    return self:getBlock(self.selectedBlock)
--end

function block:select()
    if levelbox.selectedBlock and button:exists("new" .. levelbox:getSelectedBlock().entityType) then
        button:get("new" .. levelbox:getSelectedBlock().entityType).color = button:get("new" .. levelbox:getSelectedBlock().entityType).colorUnclicked
    end
    self.selected = true
    if block and button:exists("new" .. self:getSelectedBlock().entityType) then
        button:get("new" .. levelbox:getSelectedBlock().entityType).color = button:get("new" .. levelbox:getSelectedBlock().entityType).colorClicked
    end
end

function block:draw()
    local valueScale = (50 / graphikFont:getHeight() / 3)
    love.graphics.setColor(self.color)
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
        if self.selected then
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
        elseif self.type == "Button" then
            love.graphics.draw(
                contextMenu.screens["forButton"].categories[self.category].types[self.innerType].picture,
                self.x,
                self.y,
                0,
                self.w / contextMenu.screens["forButton"].categories[self.category].types[self.innerType].picture:getWidth(),
                self.h / contextMenu.screens["forButton"].categories[self.category].types[self.innerType].picture:getHeight()
            )
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
        if name == self.selectedBlock then
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
        if name == self.game.activeSpawn then
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
    if self.entityType and button:exists("new" .. self.entityType) then
        button:get("new" .. self.entityType).color = button:get("new" .. self.entityType).colorUnclicked
    end
    self.category = category
    self.innerType = innerType
    self.entityType = contextMenu.screens["for" .. self.type].categories[category].types[innerType].sign
    button:get("new" .. self.entityType).color = button:get("new" .. self.entityType).colorClicked
end