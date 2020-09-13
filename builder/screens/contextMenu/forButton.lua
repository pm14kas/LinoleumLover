contextMenu.screens["forButton"].categories = {}

function contextMenu.screens.forButton:load()
    for kmap, loadMap in pairs(levelbox.state.maps) do
        if #loadMap.doors > 0 then
            local category = {
                value = kmap,
                types = {}
            }
            for kdoor, door in ipairs(loadMap.doors) do
                table.insert(category.types, {
                    imageFilename = "images/icons/icon_door.png",
                    sign = door,
                    trigger = function(self)
                        local triggerButton = button:get("newforButton_" .. self.sign)
                        if inArray(door, levelbox:getSelectedBlock().links) then
                            table.removeByValue(levelbox:getSelectedBlock().links, door)
                            triggerButton.color = triggerButton.colorUnclicked
                        else
                            table.insert(levelbox:getSelectedBlock().links, door)
                            triggerButton.color = triggerButton.colorClicked
                        end
                    end,
                    onhover = function(self)
                        levelbox:highlightBlock(door, kmap)
                    end,
                    offhover = function(self)
                        levelbox.state.highlightedBlock = nil
                        levelbox:getBlock(door, kmap):unhighlight()
                    end
                })
            end
            table.insert(self.categories, category)
        end
    end
end

function contextMenu.screens.forButton:reload()
    for i, buttonName in ipairs(self.buttons) do
        button:delete(buttonName)
    end
    self.buttons = {}
    self.categories = {}
    self:load()
    contextMenu:loadScreen("forButton", self)
end
