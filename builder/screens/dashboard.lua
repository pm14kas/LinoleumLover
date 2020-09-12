dashboard = screen:new("dash", {
    Y = h * 3 / 4,
    h = h / 4,
    w = w / 2,
    active = true,
    draw = true
})

function dashboard:setMapView()
    local flag = levelbox:getMapView()
    --here should lie code which turns on/off buttons
end

function dashboard:load()

    button:add(
            "deleteBlock",
            {
                X = screen:get("dash").w - buttonFont:getWidth("Delete") * 1.5 / 2,
                Y = buttonFont:getHeight() * 1.5 / 2,
                value = "Delete",
                onclick = function()
                    levelbox:deleteblock()
                end
            }
    )

    button:add(
            "mapViewTrigger",
            {
                X = button:get("deleteBlock").X - button:get("deleteBlock").width - buttonFont:getWidth("Map View") * 1.5 / 2,
                Y = buttonFont:getHeight() * 1.5 / 2,
                value = "Map View",
                onclick = function()
                    if levelbox:getMapView() then
                        if levelbox.state.selectedMap then
                            levelbox:setMapView(false)
                            button:get("mapViewTrigger").value = "Map View"
                        end
                    else
                        levelbox:setMapView(true)
                        button:get("mapViewTrigger").value = "Level View"
                    end
                end
            }
    )

    button:add(
            "Centrize",
            {
                X = button:get("deleteBlock").X - button:get("deleteBlock").width - buttonFont:getWidth("Centrize") * 1.5 / 2,
                Y = buttonFont:getHeight() * 1.5 * 4 / 2,
                value = "Centrize",
                onclick = function()
                    levelbox:centrize()
                end
            }
    )

    button:add(
            "save",
            {
                X = screen:get("dash").w - buttonFont:getWidth("Save") * 1.5 / 2,
                Y = buttonFont:getHeight() * 1.5 * 4 / 2,
                value = "Save",
                onclick = function()
                    levelbox:save()
                end
            }
    )
    -------------------------------------------------moving---------------------------------------------------
    button:add(
            "toLeft",
            {
                X = buttonFont:getHeight() * 1.5,
                Y = buttonFont:getHeight() * 1.5 / 2 + buttonFont:getHeight() * 1.5,
                width = buttonFont:getHeight() * 1.5,
                value = "l",
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).x = levelbox:getBlock(levelbox.state.selectedBlock).x - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * levelbox:getStep().w
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).x = levelbox:getMap(levelbox.state.selectedMap).x - (love.keyboard.isDown("lshift", "rshift") and 10 or 1)
                    end
                end
            }
    )

    button:add(
            "toUp",
            {
                X = button:get("toLeft").X + button:get("toLeft").width * 3 / 2,
                Y = button:get("toLeft").Y - button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "u",
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).y = levelbox:getBlock(levelbox.state.selectedBlock).y - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * levelbox:getStep().h
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).y = levelbox:getMap(levelbox.state.selectedMap).y - (love.keyboard.isDown("lshift", "rshift") and 10 or 1)
                    end
                end
            }
    )

    button:add(
            "toRight",
            {
                X = button:get("toUp").X + button:get("toUp").width * 3 / 2,
                Y = button:get("toLeft").Y + button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "r",
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).x = levelbox:getBlock(levelbox.state.selectedBlock).x + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * levelbox:getStep().w
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).x = levelbox:getMap(levelbox.state.selectedMap).x + (love.keyboard.isDown("lshift", "rshift") and 10 or 1)
                    end
                end
            }
    )

    button:add(
            "toDown",
            {
                X = button:get("toLeft").X + button:get("toLeft").width * 3 / 2,
                Y = button:get("toLeft").Y + button:get("toLeft").height * 3 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "d",
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).y = levelbox:getBlock(levelbox.state.selectedBlock).y + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * levelbox:getStep().h
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).y = levelbox:getMap(levelbox.state.selectedMap).y + (love.keyboard.isDown("lshift", "rshift") and 10 or 1)
                    end
                end
            }
    )
    -------------------------------------------------z-index---------------------------------------------------
    button:add(
            "zPlus",
            {
                X = button:get("toRight").X + button:get("toRight").width / 2,
                Y = button:get("toDown").Y + button:get("toDown").height * 3 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "z+",
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).z = levelbox:getBlock(levelbox.state.selectedBlock).z + 1
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).z = levelbox:getMap(levelbox.state.selectedMap).z + 1
                    end
                end
            }
    )

    button:add(
            "zMinus",
            {
                X = button:get("toLeft").X + button:get("toLeft").width / 2,
                Y = button:get("toDown").Y + button:get("toDown").height * 3 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "z-",
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).z = levelbox:getBlock(levelbox.state.selectedBlock).z - 1
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).z = levelbox:getMap(levelbox.state.selectedMap).z - 1
                    end
                end
            }
    )
    -------------------------------------------------grid size---------------------------------------------------
    button:add(
            "gridPlus",
            {
                X = button:get("zPlus").X + button:get("zPlus").width / 2,
                Y = button:get("zPlus").Y + button:get("zPlus").height * 2,
                width = buttonFont:getHeight() * 1.5,
                value = "g+",
                onclick = function()
                    levelbox.step.mult = levelbox.step.mult + 1
                    button:get("gridValue").value = levelbox.step.mult
                    if (levelbox.step.mult > 1) then
                        button:get("gridMinus").active = true
                    end
                    if (levelbox.step.mult >= levelbox.step.max) then
                        button:get("gridPlus").active = false
                    end
                end
            }
    )
    button:add(
            "gridValue",
            {
                X = button:get("gridPlus").X - button:get("gridPlus").width / 2,
                Y = button:get("gridPlus").Y + button:get("gridPlus").height / 2,
                width = buttonFont:getHeight() * 1.5,
                value = levelbox.step.mult,
                active = false
            }
    )
    button:add(
            "gridMinus",
            {
                X = button:get("zMinus").X + button:get("zMinus").width / 2,
                Y = button:get("zMinus").Y + button:get("zMinus").height * 2,
                width = buttonFont:getHeight() * 1.5,
                value = "g-",
                onclick = function()
                    levelbox.step.mult = levelbox.step.mult - 1
                    button:get("gridValue").value = levelbox.step.mult
                    if (levelbox.step.mult == 1) then
                        button:get("gridMinus").active = false
                    end
                    if (levelbox.step.mult < levelbox.step.max) then
                        button:get("gridPlus").active = true
                    end
                end
            }
    )
    -------------------------------------------------resize---------------------------------------------------
    button:add(
            "resizeW",
            {
                X = button:get("toRight").X + button:get("toRight").width * 5 / 2,
                Y = button:get("toRight").Y + button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).x = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).x - levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).w)
                        levelbox:getBlock(levelbox.state.selectedBlock).w = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).w + levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).x)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).x = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).x - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).w)
                        levelbox:getMap(levelbox.state.selectedMap).w = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).w + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).x)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeW").width / 2,
                            button:get("resizeW").height / 2,
                            -math.pi / 2 + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeW").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeW").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "resizeNW",
            {
                X = button:get("toRight").X + button:get("toRight").width * 5 / 2,
                Y = button:get("toRight").Y - button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).x = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).x - levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).w)
                        levelbox:getBlock(levelbox.state.selectedBlock).w = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).w + levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).x)
                        levelbox:getBlock(levelbox.state.selectedBlock).y = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).y - levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).h)
                        levelbox:getBlock(levelbox.state.selectedBlock).h = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).h + levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).y)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).x = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).x - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).w)
                        levelbox:getMap(levelbox.state.selectedMap).w = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).w + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).x)
                        levelbox:getMap(levelbox.state.selectedMap).y = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).y - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).h)
                        levelbox:getMap(levelbox.state.selectedMap).h = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).h + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).y)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeNW").width / 2,
                            button:get("resizeNW").height / 2,
                            -math.pi / 4 + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeNW").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeNW").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "resizeN",
            {
                X = button:get("toRight").X + button:get("toRight").width * 7 / 2,
                Y = button:get("toRight").Y - button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).y = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).y - levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).h)
                        levelbox:getBlock(levelbox.state.selectedBlock).h = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).h + levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).y)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).y = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).y - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).h)
                        levelbox:getMap(levelbox.state.selectedMap).h = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).h + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).y)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeN").width / 2,
                            button:get("resizeN").height / 2,
                            0 + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeN").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeN").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "resizeNE",
            {
                X = button:get("toRight").X + button:get("toRight").width * 9 / 2,
                Y = button:get("toRight").Y - button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).w = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).w + levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).x)
                        levelbox:getBlock(levelbox.state.selectedBlock).y = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).y - levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).h)
                        levelbox:getBlock(levelbox.state.selectedBlock).h = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).h + levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).y)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).w = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).w + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).x)
                        levelbox:getMap(levelbox.state.selectedMap).y = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).y - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).h)
                        levelbox:getMap(levelbox.state.selectedMap).h = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).h + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).y)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeNE").width / 2,
                            button:get("resizeNE").height / 2,
                            math.pi / 4 + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeNE").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeNE").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "resizeE",
            {
                X = button:get("toRight").X + button:get("toRight").width * 9 / 2,
                Y = button:get("toRight").Y + button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).w = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).w + levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).x)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).w = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).w + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).x)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeE").width / 2,
                            button:get("resizeE").height / 2,
                            math.pi / 2 + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeE").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeE").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "resizeSE",
            {
                X = button:get("toRight").X + button:get("toRight").width * 9 / 2,
                Y = button:get("toRight").Y + button:get("toLeft").height * 3 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).w = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).w + levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).x)
                        levelbox:getBlock(levelbox.state.selectedBlock).h = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).h + levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).y)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).w = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).w + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).x)
                        levelbox:getMap(levelbox.state.selectedMap).h = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).h + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).y)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeSE").width / 2,
                            button:get("resizeSE").height / 2,
                            3 * math.pi / 4 + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeSE").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeSE").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "resizeS",
            {
                X = button:get("toRight").X + button:get("toRight").width * 7 / 2,
                Y = button:get("toRight").Y + button:get("toLeft").height * 3 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).h = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).h + levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).y)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).h = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).h + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).y)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeS").width / 2,
                            button:get("resizeS").height / 2,
                            math.pi + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeS").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeS").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "resizeSW",
            {
                X = button:get("toRight").X + button:get("toRight").width * 5 / 2,
                Y = button:get("toRight").Y + button:get("toLeft").height * 3 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        levelbox:getBlock(levelbox.state.selectedBlock).x = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).x - levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).w)
                        levelbox:getBlock(levelbox.state.selectedBlock).w = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).w + levelbox:getStep().w * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getBlock(levelbox.state.selectedBlock).x)
                        levelbox:getBlock(levelbox.state.selectedBlock).h = math.min(math.max(0, levelbox:getBlock(levelbox.state.selectedBlock).h + levelbox:getStep().h * (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getBlock(levelbox.state.selectedBlock).y)
                    elseif levelbox.state.selectedMap then
                        levelbox:getMap(levelbox.state.selectedMap).x = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).x - (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).w)
                        levelbox:getMap(levelbox.state.selectedMap).w = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).w + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.w - levelbox:getMap(levelbox.state.selectedMap).x)
                        levelbox:getMap(levelbox.state.selectedMap).h = math.min(math.max(0, levelbox:getMap(levelbox.state.selectedMap).h + (love.keyboard.isDown("lshift", "rshift") and 10 or 1) * (love.keyboard.isDown("lctrl", "rctrl") and -1 or 1)), levelbox.h - levelbox:getMap(levelbox.state.selectedMap).y)
                    end
                end,
                picture = function()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(
                            arrowPic,
                            button:get("resizeSW").width / 2,
                            button:get("resizeSW").height / 2,
                            -3 * math.pi / 4 + (love.keyboard.isDown("lctrl", "rctrl") and math.pi or 0),
                            button:get("resizeSW").width / (math.sqrt(2) * arrowPic:getWidth()),
                            button:get("resizeSW").height / (math.sqrt(2) * arrowPic:getHeight()),
                            arrowPic:getWidth() / 2,
                            arrowPic:getHeight() / 2
                    )
                end
            }
    )
    button:add(
            "rotate",
            {
                X = button:get("toRight").X + button:get("toRight").width * 7 / 2,
                Y = button:get("toRight").Y + button:get("toLeft").height * 1 / 2,
                width = buttonFont:getHeight() * 1.5,
                value = "",
                shadowX = 0,
                shadowY = 0,
                onclick = function()
                    if levelbox.state.selectedBlock then
                        local t = levelbox:getBlock(levelbox.state.selectedBlock).w
                        levelbox:getBlock(levelbox.state.selectedBlock).w = levelbox:getBlock(levelbox.state.selectedBlock).h
                        levelbox:getBlock(levelbox.state.selectedBlock).h = t
                    elseif levelbox.state.selectedMap then
                        local t = levelbox:getMap(levelbox.state.selectedMap).w
                        levelbox:getMap(levelbox.state.selectedMap).w = levelbox:getMap(levelbox.state.selectedMap).h
                        levelbox:getMap(levelbox.state.selectedMap).h = t
                    end
                end,
                backgroundImage = rotatePic
            }
    )
end