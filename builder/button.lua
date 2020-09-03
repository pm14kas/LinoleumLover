button = {
	b={},
	default = {
		value = "Push!",
		rx = 4,
		ry = 4,
		segments = 40,
		shadowX = 2,
		shadowY = 2,
		incrX = 0,
		incrY = 0,
		onclick = function() end,
		onpress = function() end,
		onhover = function() end,
		font = love.graphics.newFont("fonts/joystix monospace.ttf", fontSize),
		font1 = love.graphics.newFont("fonts/joystix monospace.ttf", fontSize + 2),
		fontColor = {255, 255, 255},
		screen = "dash",
		picture = function() end
	}
}

function button:click(name)
	--self:get(name).incrX = self:get(name).incrX + self:get(name).shadowX - 1
	self:get(name).incrY = math.max(self:get(name).incrY + self:get(name).shadowY - 1, 0)
	self:get(name).color = self:get(name).colorClicked
	self:get(name).onpress()
end

function button:release(name)
	--self:get(name).incrX = self:get(name).incrX - self:get(name).shadowX + 1
	self:get(name).incrY = 0
	self:get(name).color = self:get(name).colorUnclicked
	self:get(name).onclick()
end

function button:add(name, params)
	self.b[name] = {}
	if not params then params = {} end
	for k,v in pairs(self.default) do
		self:get(name)[k] = params[k] or v
	end
	self:get(name).width  = params.width  or self:get(name).font:getWidth (self:get(name).value) * 1.5
	self:get(name).height = params.height or self:get(name).font:getHeight() * 1.5
	self:get(name).X = (params.X == "center" and (screen:get(self:get(name).screen).w - self:get(name).width)  / 2) or params.X ~= nil and params.X - button:get(name).width  / 2 or 0
	self:get(name).Y = (params.Y == "center" and (screen:get(self:get(name).screen).h - self:get(name).height) / 2) or params.Y ~= nil and params.Y - button:get(name).height / 2 or 0
	self:get(name).backgroundImage = params.backgroundImage
	self:get(name).color = params.color or {255, 0, 0}
	self:get(name).colorUnclicked = params.color or {255, 0, 0}
	self:get(name).colorClicked = params.colorClicked or {255, 125, 0}
	self:get(name).draw = params.draw == nil and true or params.draw
	self:get(name).active = params.active == nil and true or params.active
	self:get(name).userData = params.userData or {}
	table.insert(screen:get(self:get(name).screen).buttons, name)
end

function button:delete(name)
	table.remove(screen:get(self:get(name).screen).buttons, name)
	table.remove(self.b, name)
end

function button:draw(name)
	if not self:exists(name) then
		error("button " .. name .. " doesn't exist.")
	end
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle(--shadowButton
		"fill", 
		button:get(name).X,--+button:get(name).shadowX, 
		button:get(name).Y + button:get(name).shadowY, 
		button:get(name).width, 
		button:get(name).height, 
		button:get(name).rx, 
		button:get(name).ry, 
		button:get(name).segments
	)


	love.graphics.setColor(button:get(name).color)
	love.graphics.rectangle(
		"fill", 
		button:get(name).X + button:get(name).incrX, 
		button:get(name).Y + button:get(name).incrY, 
		button:get(name).width, 
		button:get(name).height, 
		button:get(name).rx, 
		button:get(name).ry, 
		button:get(name).segments
	)

	if button:get(name).backgroundImage then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(
			button:get(name).backgroundImage, 
			button:get(name).X + button:get(name).incrX + (2 * button:get(name).width  - math.sqrt(2) * button:get(name).width ) / 4, 
			button:get(name).Y + button:get(name).incrY + (2 * button:get(name).height - math.sqrt(2) * button:get(name).height) / 4, 
			0, 
			button:get(name).width  / (math.sqrt(2)*button:get(name).backgroundImage:getWidth() ), 
			button:get(name).height / (math.sqrt(2)*button:get(name).backgroundImage:getHeight())
		)
	end

	if button:get(name).picture then
		love.graphics.translate(button:get(name).X, button:get(name).Y)
		button:get(name).picture()
		love.graphics.translate(-button:get(name).X, -button:get(name).Y)
	end
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(button:get(name).font)
	love.graphics.print(--shadowText
		button:get(name).value, 
		button:get(name).X + (button:get(name).width  - button:get(name).font:getWidth(button:get(name).value)) * 0.5 + button:get(name).incrX + 1, 
		button:get(name).Y + (button:get(name).height - button:get(name).font:getHeight()) / 2 + button:get(name).incrY + 1
	)

	-- if(self:hovered(name)) then
	-- 	love.graphics.setColor(0, 0, 0)
	-- 	button:get(name).onhover()
	-- else
	-- 	love.graphics.setColor(button:get(name).fontColor)
	-- end
	love.graphics.setColor(button:get(name).fontColor)
	love.graphics.print(
		button:get(name).value, 
		button:get(name).X + (button:get(name).width  - button:get(name).font:getWidth(button:get(name).value)) * 0.5 + button:get(name).incrX, 
		button:get(name).Y + (button:get(name).height - button:get(name).font:getHeight()) / 2 + button:get(name).incrY
	)
end

function button:exists(name)
	return button.b[name] ~= nil
end

function button:hovered(name)
	return  cursor.x > button:get(name).X
		and cursor.x < button:get(name).X + button:get(name).width
		and cursor.y > button:get(name).Y
		and cursor.y < button:get(name).Y + button:get(name).height 
end

function button:get(name)
	if not self:exists(name) then
		error("button " .. name .. " doesn't exist")
	end
	return self.b[name]
end