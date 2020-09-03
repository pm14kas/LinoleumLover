itemView = screen:new("itemView", {
	X = w * 3 / 4+5,
	h = h / 2,
	w = w / 4-5,
	active = true, 
	draw = true
})

itemView.screenNamesLevelView = {
	"basicBlocks",
	"decorBlocks"
}

itemView.screenNamesMapView = {
	"mapBasicBlocks",
	"mapBlocks"
}

itemView.screens = {}
itemView.activeScreen = "basicBlocks"

function itemView:triggerMapView(flag)
	for i, screenName in ipairs(itemView.screenNamesLevelView) do
		button:get(screenName .. "Trigger").draw = not flag
		button:get(screenName .. "Trigger").active = not flag
	end

	for i, screenName in ipairs(itemView.screenNamesMapView) do
		button:get(screenName .. "Trigger").draw = flag
		button:get(screenName .. "Trigger").active = flag
	end
	itemView:setActiveScreen(flag and itemView.screenNamesMapView[1] or itemView.screenNamesLevelView[1])
end

function itemView:setActiveScreen(screenName)
	if self.activeScreen then
		screen:get(self.activeScreen).active = false
		screen:get(self.activeScreen).draw = false

		button:get(self.activeScreen .. "Trigger").color = button:get(self.activeScreen .. "Trigger").colorUnclicked
	end
	if screenName then
		screen:get(screenName).active = true
		screen:get(screenName).draw = true

		button:get(screenName .. "Trigger").color = button:get(screenName .. "Trigger").colorClicked
	end

	self.activeScreen = screenName
end

function itemView:show()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, self.w, self.h)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, button:get("basicBlocksTrigger").height, self.w, 3)
end

for i, screenName in ipairs(itemView.screenNamesLevelView) do
	button:add(
		screenName .. "Trigger",
		{
			X = screen:get("itemView").w / #itemView.screenNamesLevelView / 2 * (i * 2 - 1),
			Y = buttonFont:getHeight() * 1.5 / 2,
			width = screen:get("itemView").w / #itemView.screenNamesLevelView,
			value = screenName:sub(1, -7),
			screen = "itemView",
			shadowX = 0,
			shadowY = 0,
			segments = 0,
			rx = 0,
			ry = 0,
			onclick = function()
				itemView:setActiveScreen(screenName)

				button:get(screenName .. "Trigger").color = button:get(screenName .. "Trigger").colorClicked
			end
		}
	)
end

for i, screenName in ipairs(itemView.screenNamesMapView) do
	button:add(
		screenName .. "Trigger",
		{
			X = screen:get("itemView").w / #itemView.screenNamesMapView / 2 * (i * 2 - 1),
			Y = buttonFont:getHeight() * 1.5 / 2,
			width = screen:get("itemView").w / #itemView.screenNamesMapView,
			value = screenName:sub(1, -7),
			screen = "itemView",
			shadowX = 0,
			shadowY = 0,
			segments = 0,
			rx = 0,
			ry = 0,
			active = false,
			draw = false,
			onclick = function()
				itemView:setActiveScreen(screenName)

				button:get(screenName .. "Trigger").color = button:get(screenName .. "Trigger").colorClicked
			end
		}
	)
end

for i, screenName in ipairs(itemView.screenNamesLevelView) do
	itemView.screens[screenName] = screen:new(screenName, {
		X = itemView.X,
		Y = button:get("basicBlocksTrigger").height + 3,
		w = itemView.w,
		h = itemView.h - button:get("basicBlocksTrigger").height - 3,
		active = i == 1, 
		draw = i == 1
	})
	itemView.screens[screenName].settings = {
		inRow = 4
	}
end

for i, screenName in ipairs(itemView.screenNamesMapView) do
	itemView.screens[screenName] = screen:new(screenName, {
		X = itemView.X,
		Y = button:get("basicBlocksTrigger").height + 3,
		w = itemView.w,
		h = itemView.h - button:get("basicBlocksTrigger").height - 3,
		active = false, 
		draw = false
	})
	itemView.screens[screenName].settings = {
		inRow = 4
	}
end

for k, file in ipairs(love.filesystem.getDirectoryItems("screens/itemView")) do
	require("screens/itemView/" .. file:sub(1,-5))
end

for kscreen, screenContext in pairs(itemView.screens) do
	if screenContext.types then
		for i, block in ipairs(screenContext.types) do
			block.picture = love.graphics.newImage(block.imageFilename)
			block.cursor = love.mouse.newCursor(block.imageFilename, 32, 32)
			local buttonWidth = screenContext.w / screenContext.settings.inRow
			button:add(
				"new"..block.sign,
				{
					X = buttonWidth / 2 + buttonWidth * ((i - 1) % screenContext.settings.inRow),
					Y = buttonWidth / 2 + buttonWidth * math.floor((i - 1) / screenContext.settings.inRow),
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
						block.new()
						love.mouse.setCursor(cursorSt)
					end,
					onpress = function()
						love.mouse.setCursor(block.cursor)
					end
				}
			)
		end
	end
end