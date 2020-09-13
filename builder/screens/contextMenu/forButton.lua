contextMenu.screens["forButton"].categories = {}

function contextMenu.screens.forButton:load()
    print(self.loadPriority)
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
                    trigger = function()
                        levelbox:getSelectedBlock()
                    end,
                    onhover = function()
                        levelbox:highlightBlock(door, kmap)
                    end,
                    offhover = function()
                        levelbox:highlightBlock()
                    end
                })
            end
            table.insert(self.categories, category)
        end
    end
end