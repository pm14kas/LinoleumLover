screen = {
	default = {
		X = 0,
		Y = 0,
		w = w,
		h = h,
		offsetX = 0,
		offsetY = 0,
		scaleX = 1,
		scaleY = 1,
		draw = false,
		z = 1,
		active = false,
		show = function() end
	},
	s = {}
}

function screen:new(name, params)
	self.s[name] = {}
	if not params then params = {} end
	for k,v in pairs(screen.default) do
		self.s[name][k] = params[k] or v
	end
	self.s[name].buttons = {}
	self.s[name].maxX = self.s[name].w
	self.s[name].maxY = self.s[name].h
	return self.s[name]
end

function screen:load(name)
    self:get(name):load()
end

function screen:getAll()
    return pairs(self.s)
end

function screen:show(name)
	if name == nil then error("oops") end
	love.graphics.setScissor(self:get(name).X, self:get(name).Y, self:get(name).w, self:get(name).h)
	love.graphics.translate(self:get(name).X + self:get(name).offsetX, self:get(name).Y + self:get(name).offsetY)
	love.graphics.scale(self:get(name).scaleX, self:get(name).scaleY)
	cursor.x, cursor.y = cursor.x / self:get(name).scaleX - self:get(name).X, cursor.y / self:get(name).scaleY - self:get(name).Y
	self:get(name):show()
	for index, b in ipairs(self:get(name).buttons) do
		if button:get(b).draw then
			button:draw(b)
		end
	end
	love.graphics.scale(1 / self:get(name).scaleX, 1 / self:get(name).scaleY)
	love.graphics.origin()
	cursor.x, cursor.y = cursor.x + self:get(name).X * self:get(name).scaleX, cursor.y + self:get(name).Y * self:get(name).scaleY
	love.graphics.setScissor()
end

function screen:get(name)
	if not self:exists(name) then
		error("screen " .. name .. " doesn't exist")
	end
	return self.s[name]
end

function screen:exists(name)
	return self.s[name] ~= nil
end

function screen:orderBy(key, order)
	if order then
		order = order:lower()
	else
		order = "asc"
	end
	local values = {}
	local keys = {}
	for k,v in pairs(self.s) do
		table.insert(values, v[key])
		table.insert(keys, k)
	end
	for i = 1, table.getn(values), 1 do
		for j = 1, table.getn(values), 1 do
			if((order == "asc" and values[j] > values[i]) or (order == "desc" and values[j] < values[i])) then
				temp = values[i]
				values[i] = values[j]
				values[j]= temp
				temp = keys[i]
				keys[i] = keys[j]
				keys[j]= temp
			end
		end
	end
	local k = 0
	local iter = function()   -- iterator function
		k = k + 1
		if keys[k] == nil then return nil
		else return keys[k], self.s[keys[k]]
		end
	end
	return iter
end