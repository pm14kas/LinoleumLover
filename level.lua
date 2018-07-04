level = {};

function level:new()
	self.data = file_exists("map.linoleum") and json.decode(encrypt(read_file("map.linoleum"), "Hui")) or
	{
		["map0"] = {
			x = 0,
			y = 0,
			w = 30,
			h = 30,
			border = 10,
			borderW = 5,
			color = {1, 0, 0},
			grabbedX = 25,
			grabbedY = 50,
			value = "m0",
			type = "map",
			blocks = {},
			spawns = {},
			targets = {},
			blocksCount = 0,
		}
	};
	self.blocks = {};
	self.spawns = {};
	self.portals = {};
	self.hazards = {};
	self.decorations = {};
	self.activeSpawn = self.data.activeSpawn;
	self:clearBlocks();
end

function level:goToSpawn(spawnName, force)
	if (spawnName and (spawnName ~= "")) then
		map, pureSpawn = level:parseBlockName(spawnName);
		if (map == self.activeMap and not force) then
			for k, block in pairs(self.data.maps[self.activeMap].spawns) do
				if (spawnName == k) then
					player:teleport(block.x, block.y);
					break;
				end
			end
		else
			if force then
				love.graphics.clear(1, 0, 0)
				love.graphics.present()
			else
				love.graphics.clear(0, 0, 0)
				love.graphics.present()
			end
			love.graphics.present()
			level:changeLevel(map, spawnName);
		end
	end 
end

function level:changeLevel(levelId, spawnId)
	self:clearBlocks();
	self:new();
	
	if not self.data.maps[levelId] then 
		levelId = self.activeMap;
	end
	
	self.activeMap = levelId;

	for k, block in pairs(self.data.maps[self.activeMap].blocks) do
		self:appendBlock(block.x, block.y, block.w, block.h, block.color);
	end	
	
	for k, block in pairs(self.data.maps[self.activeMap].hazards) do
		self:appendHazard(block.x, block.y, block.w, block.h);
	end	
	
	for k, block in pairs(self.data.maps[self.activeMap].targets) do
		self:appendPortal(block.x, block.y, block.w, block.h, block.spawn);
	end		
	
	for k, block in pairs(self.data.maps[self.activeMap].decorations) do
		self:appendDecoration(block.x, block.y, block.w, block.h, block.color, block.type, block.value);
	end	
	
	for k, block in pairs(self.data.maps[self.activeMap].spawns) do
		if (self.activeSpawn == nil) then
			self.activeSpawn = k;
		end
		parsedMapName, parsedSpawnName = self:parseBlockName(k);
		if (spawnId == k) then
			player:respawn(block.x, block.y);
		end
	end

	self:appendBlock(0, -1, layout.w, 1); --top
	self:appendBlock(0, layout.h, layout.w, 1); -- bottom
	self:appendBlock(-1, 0, 1, layout.h); -- left
	self:appendBlock(layout.w, 0, 1, layout.h); -- right
end

function level:appendBlock(x, y, width, height, color)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	if not color then color = {1, 1, 1} end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.startX = layout.getX(x); 
	block.startY = layout.getY(y); 
	-- because misha is gay
	block.startX = block.startX + block.width * 0.5;
	block.startY = block.startY + block.height * 0.5;
	block.color = color;
	block.body = love.physics.newBody(world, block.startX, block.startY, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	table.insert(self.blocks, block);
end

function level:appendHazard(x, y, width, height)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.startX = layout.getX(x); 
	block.startY = layout.getY(y); 
	-- because misha is gay
	block.startX = block.startX + block.width * 0.5;
	block.startY = block.startY + block.height * 0.5;
	block.body = love.physics.newBody(world, block.startX, block.startY, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	table.insert(self.hazards, block);
end

function level:appendPortal(x, y, width, height, spawn)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.startX = layout.getX(x); 
	block.startY = layout.getY(y); 
	-- because misha is gay
	block.startX = block.startX + block.width * 0.5;
	block.startY = block.startY + block.height * 0.5;
	block.color = {1,1,1};
	block.spawn = spawn;
	
	block.body = love.physics.newBody(world, block.startX, block.startY, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	if block.spawn and block.spawn ~= "" then
		block.fixture:setSensor(true);
	end
	table.insert(self.portals, block);
end

function level:appendDecoration(x, y, width, height, color, type, value)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.x = layout.getX(x); 
	block.y = layout.getY(y); 

	block.color = {1,1,1};
	block.type = type;
	block.value = value;
	block.color = color;
	table.insert(self.decorations, block);
end

function level:clearBlocks()
	for k, block in pairs(self.blocks) do
		block.body:destroy();
	end
	for k, block in pairs(self.portals) do
		block.body:destroy();
	end
	for k, block in pairs(self.hazards) do
		block.body:destroy();
	end
	self.blocks = {};
	self.portals = {};
	self.hazards = {};
	self.decorations = {};
end

function level:parseBlockName(blockName)
	tempArray = self:splitString(blockName, "_");
	return tempArray[1], tempArray[2];
end

function level:splitString(inputstr, sep)
	if sep == nil then
		sep = "_";
	end
	local t={};
	local i=1;
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str;
		i = i + 1;
	end
	return t;
end

function level:trimDigits(inputstr)
	for str in string.gmatch(inputstr, "([^[0-9]]+)") do
		return str;
	end
end


function level:draw()
	if viewMode then
		love.graphics.setBackgroundColor(self.data.maps[self.activeMap].backgroundColor);
		
		for k, block in pairs(self.decorations) do
			love.graphics.setColor(block.color)
			love.graphics.printf( 
				block.value, 
				block.x, 
				block.y, 
				math.max(block.width, love.graphics.getFont():getWidth(block.value)), 
				"left", 
				0, 
				(block.width) / love.graphics.getFont():getWidth(block.value), 
				(block.height) / love.graphics.getFont():getHeight() 
			)
		end
		
		for k, v in ipairs(self.blocks) do
			love.graphics.setColor(v.color)
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
		love.graphics.setColor({1, math.sin(love.timer.getTime()*10) * 0.5 + 0.5, 0.1});
		for k, v in ipairs(self.hazards) do
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
		
		for k, v in ipairs(self.portals) do
			love.graphics.setColor(v.color)
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
		
		if (self.target) then
			love.graphics.setColor(self.target.color)
			love.graphics.polygon("fill", self.target.body:getWorldPoints(self.target.shape:getPoints()))
		end
	else
		love.graphics.setBackgroundColor(204 / 255,153 / 255,72 / 255);
		for k, map in pairs(self.data.maps) do
			if k ~= "activeSpawn" then
				love.graphics.setColor(map.backgroundColor);
				love.graphics.rectangle("fill", map.x, map.y, map.w, map.h);
				if k == self.activeMap then
					love.graphics.setColor(1, 1, 1);
					love.graphics.line(
						map.x,
						map.y, 
						map.x + map.w,
						map.y + map.h
					);
					love.graphics.line(
						map.x + map.w,
						map.y, 
						map.x,
						map.y + map.h
					);
				end
			end
		end
	end
end