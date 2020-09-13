contextMenu = screen:new("contextMenu", {
	X = w * 3 / 4+5,
	Y = h / 2,
	h = h / 2,
	w = w / 4-5,
	active = true, 
	draw = true
})

contextMenu.screenNames = {
	"forAI",
	"forBlock",
	"forCheckpoint",
	"forHazard",
	"forItem",
	"forPortal",
	"forSpawn",
	"forText",
	"forButton",
	"forDoor"
}

contextMenu.screens = {}

for i, screenName in ipairs(contextMenu.screenNames) do
	contextMenu.screens[screenName] = screen:new(screenName, {
		X = contextMenu.X,
		Y = contextMenu.Y,
		w = contextMenu.w,
		h = contextMenu.h,
		active = false, 
		draw = false,
        loadPriority = contextMenu.loadPriority + 1
	})
	contextMenu.screens[screenName].settings = {
		inRow = 4
	}
end

contextMenu.activeScreen = nil

contextMenu.path = "screens/contextMenu"
for k, file in ipairs(love.filesystem.getDirectoryItems(contextMenu.path)) do
    require(contextMenu.path .. "/" .. file:sub(1,-5))
end

function contextMenu:show()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, self.w, self.h)
	--love.graphics.rectangle("line", 0, 0, self.w, self.h / 2)
end

function contextMenu:setActiveScreen(screenName)
	if self.activeScreen then
		screen:get(self.activeScreen).active = false
		screen:get(self.activeScreen).draw = false
	end
	if screenName then
		screen:get(screenName).active = true
		screen:get(screenName).draw = true
	end

	self.activeScreen = screenName
end

function contextMenu:load()
    for kscreen, screenContext in pairs(contextMenu.screens) do
        self:loadScreen(kscreen, screenContext)
    end
end

function contextMenu:getButtonName(kscreen, sign)
    return "new" .. kscreen .. "_" .. sign
end

function contextMenu:loadScreen(kscreen, screenContext)
    if screenContext.categories then
        local buttonWidth = screenContext.w / screenContext.settings.inRow
        local heightUsed = 0
        screenContext.show = function(self)
            local height = 0
            for icat, category in ipairs(self.categories) do
                love.graphics.setFont(buttonFont)
                love.graphics.print(category.value, 0, height)
                height = height + buttonWidth * math.ceil(#category.types / self.settings.inRow) + buttonFont:getHeight()
            end
        end
        heightUsed = 0
        for icat, category in ipairs(screenContext.categories) do
            heightUsed = heightUsed + buttonFont:getHeight()
            for i, block in ipairs(category.types) do
                if not block.trigger then
                    block.trigger = function()
                        levelbox:getSelectedBlock():setType(icat, i)
                    end
                end
                if not block.onhover then
                    block.onhover = function() end
                end
                if not block.offhover then
                    block.offhover = function() end
                end
                block.picture = love.graphics.newImage(block.imageFilename)
                block.cursor = love.mouse.newCursor(block.imageFilename, block.picture:getWidth() / 2, block.picture:getHeight() / 2) -- since all item pictures are 64x64
                local buttonName = contextMenu:getButtonName(kscreen, block.sign)
                local params = {
                    X = buttonWidth / 2 + buttonWidth * ((i - 1) % screenContext.settings.inRow),
                    Y = buttonWidth / 2 + buttonWidth * math.floor((i - 1) / screenContext.settings.inRow) + heightUsed,
                    width  = buttonWidth,
                    height = buttonWidth,
                    value = "",
                    screen = kscreen,
                    shadowX = 0,
                    shadowY = 0,
                    segments = 0,
                    rx = 0,
                    ry = 0,
                    picture = function()
                        love.graphics.setColor(1,1,1)
                        love.graphics.rectangle("line", 0, 0, button:get(buttonName).width, button:get(buttonName).height)
                        local scale = button:get(buttonName).width * 3 / 4 / block.picture:getWidth()
                        love.graphics.draw(block.picture, 0, 0, 0, scale, scale, -block.picture:getWidth() / 6)
                        love.graphics.setFont(bigFont)
                        scale = math.min((button:get(buttonName).width - 20)  / love.graphics.getFont():getWidth(block.sign), button:get(buttonName).height / 5 / love.graphics.getFont():getHeight())
                        love.graphics.printf(
                            block.sign,
                            ((button:get(buttonName).width) - love.graphics.getFont():getWidth(block.sign) * scale) / 2,
                            button:get(buttonName).height * 3 / 4 + (button:get(buttonName).height / 4 - love.graphics.getFont():getHeight() * scale) / 2,
                            math.max(button:get(buttonName).width, love.graphics.getFont():getWidth(block.sign)),
                            "center",
                            0,
                            scale,
                            scale
                        )
                    end,
                    onclick = function()
                        block:trigger()
                    end,
                    onhover = function()
                        block:onhover()
                    end,
                    offhover = function()
                        block:offhover()
                    end
                }
                if block.color then params.color = block.color end
                button:add(buttonName, params)
            end
            heightUsed = heightUsed + buttonWidth * math.ceil(#category.types / screenContext.settings.inRow)
        end
        screenContext.maxY = heightUsed
    end
end