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
		offhover = function() end,
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
	self:get(name).colorHovered = params.colorHovered or {255, 125, 0}
	self:get(name).draw = params.draw == nil and true or params.draw
	self:get(name).active = params.active == nil and true or params.active
	self:get(name).onhoverTriggered = false
	self:get(name).offhoverTriggered = true
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
		self:get(name).X,--+self:get(name).shadowX,
		self:get(name).Y + self:get(name).shadowY,
		self:get(name).width,
		self:get(name).height,
		self:get(name).rx,
		self:get(name).ry,
		self:get(name).segments
	)


	love.graphics.setColor(self:get(name).color)
	love.graphics.rectangle(
		"fill", 
		self:get(name).X + self:get(name).incrX,
		self:get(name).Y + self:get(name).incrY,
		self:get(name).width,
		self:get(name).height,
		self:get(name).rx,
		self:get(name).ry,
		self:get(name).segments
	)

	if self:get(name).backgroundImage then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(
			self:get(name).backgroundImage,
			self:get(name).X + self:get(name).incrX + (2 * self:get(name).width  - math.sqrt(2) * self:get(name).width ) / 4,
			self:get(name).Y + self:get(name).incrY + (2 * self:get(name).height - math.sqrt(2) * self:get(name).height) / 4,
			0, 
			self:get(name).width  / (math.sqrt(2)*self:get(name).backgroundImage:getWidth() ),
			self:get(name).height / (math.sqrt(2)*self:get(name).backgroundImage:getHeight())
		)
	end

	if self:get(name).picture then
		love.graphics.translate(self:get(name).X, self:get(name).Y)
		self:get(name).picture()
		love.graphics.translate(-self:get(name).X, -self:get(name).Y)
	end
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(self:get(name).font)
	love.graphics.print(--shadowText
		self:get(name).value,
		self:get(name).X + (self:get(name).width  - self:get(name).font:getWidth(self:get(name).value)) * 0.5 + self:get(name).incrX + 1,
		self:get(name).Y + (self:get(name).height - self:get(name).font:getHeight()) / 2 + self:get(name).incrY + 1
	)

	 if self:hovered(name) then
         love.graphics.setColor(self:get(name).colorHovered)
         if not self:get(name).onhoverTriggered then
             self:get(name).onhover()
             self:get(name).onhoverTriggered = true
             self:get(name).offhoverTriggered = false
         end
	 else
         if not self:get(name).offhoverTriggered then
             self:get(name).offhover()
             self:get(name).offhoverTriggered = true
             self:get(name).onhoverTriggered = false
         end
         love.graphics.setColor(self:get(name).fontColor)
	 end
	love.graphics.setColor(self:get(name).fontColor)
	love.graphics.print(
		self:get(name).value,
		self:get(name).X + (self:get(name).width  - self:get(name).font:getWidth(self:get(name).value)) * 0.5 + self:get(name).incrX,
		self:get(name).Y + (self:get(name).height - self:get(name).font:getHeight()) / 2 + self:get(name).incrY
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