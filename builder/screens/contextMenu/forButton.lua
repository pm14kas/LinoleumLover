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
                        if levelbox:getSelectedBlock().links[door .. kmap] then
                            levelbox:getSelectedBlock().links[door .. kmap] = nil
                            levelbox:getBlock(door).links[levelbox:getSelectedBlock().name .. levelbox:getSelectedBlock().map] = nil
                            triggerButton.color = triggerButton.colorUnclicked
                        else
                            levelbox:getSelectedBlock().links[door .. kmap] = {
                                name = door,
                                map = kmap
                            }
                            levelbox:getBlock(door).links[levelbox:getSelectedBlock().name .. levelbox:getSelectedBlock().map] = {
                                name = levelbox:getSelectedBlock().name,
                                map = levelbox:getSelectedBlock().map,
                            }
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
