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
		draw = false
	})
	contextMenu.screens[screenName].settings = {
		inRow = 4
	}
end

contextMenu.activeScreen = nil

contextMenu.path = "screens/contextMenu"

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

for k, file in ipairs(love.filesystem.getDirectoryItems(contextMenu.path)) do
	require(contextMenu.path .. "/" .. file:sub(1,-5))
end

for kscreen, screenContext in pairs(contextMenu.screens) do
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
				block.picture = love.graphics.newImage(block.imageFilename)
				block.cursor = love.mouse.newCursor(block.imageFilename, block.picture:getWidth() / 2, block.picture:getHeight() / 2) -- since all item pictures are 64x64
				button:add(
					"new"..block.sign,
					{
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
							love.graphics.rectangle("line", 0, 0, button:get("new"..block.sign).width, button:get("new"..block.sign).height)
							local scale = button:get("new"..block.sign).width * 3 / 4 / block.picture:getWidth()
							love.graphics.draw(block.picture, 0, 0, 0, scale, scale, -block.picture:getWidth() / 6)
							love.graphics.setFont(bigFont)
							scale = math.min((button:get("new"..block.sign).width - 20)  / love.graphics.getFont():getWidth(block.sign), button:get("new"..block.sign).height / 5 / love.graphics.getFont():getHeight())
							love.graphics.printf(
								block.sign, 
								((button:get("new"..block.sign).width) - love.graphics.getFont():getWidth(block.sign) * scale) / 2, 
								button:get("new"..block.sign).height * 3 / 4 + (button:get("new"..block.sign).height / 4 - love.graphics.getFont():getHeight() * scale) / 2,
								math.max(button:get("new"..block.sign).width, love.graphics.getFont():getWidth(block.sign)),
								"center", 
								0, 
								scale, 
								scale
							)
						end,
						onclick = function()
							block.trigger()
						end
					}
				)
			end
			heightUsed = heightUsed + buttonWidth * math.ceil(#category.types / screenContext.settings.inRow)
		end
		screenContext.maxY = heightUsed
	end
end