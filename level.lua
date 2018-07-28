level = {};
level.blockNameList = {
	map = "Map",
	portal = "Portal",
	spawn = "Spawn",
	block = "Block",
	blockSolid = "Solid",
	blockBreakable = "Breakable",
	hazard = "Hazard",
	checkpoint = "Checkpoint",
	item = "Item",
	itemDash = "Dash",
	itemDoubleJump = "Doublejump",
	itemWallClimb = "Wallclimb"
};
level.itemList = {};

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
			type = level.blockNameList.map,
			blocks = {},
			spawns = {},
			portals = {},
			decorations = {},
			checkpoints = {},
			ai = {},
			items = {},
			blocksCount = 0
		}
	};
	self.blocks = {};
	self.spawns = {};
	self.portals = {};
	self.hazards = {};
	self.decorations = {};
	self.checkpoints = {};
	self.ai = {};
	self.items = {};
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
			static.isLoading = true;
			if force then
				love.graphics.clear(1, 0, 0);
				love.graphics.present();
				love.graphics.clear(1, 0, 0);
				love.graphics.present();
				love.graphics.clear(1, 0, 0);
			else
				love.graphics.clear(0, 0, 0);
				love.graphics.present();
				love.graphics.clear(0, 0, 0);
				love.graphics.present();
				love.graphics.clear(0, 0, 0);
			end
			level:changeLevel(map, spawnName);
		end
	end 
end

function level:changeLevel(levelId, spawnId)
	love.graphics.present();
	
	if self.activeMap then --and (not self.itemList[self.activeMap])) then
		self.itemList[self.activeMap] = {};
	end
	
	for k, v in ipairs(self.items) do
		self.itemList[self.activeMap][v.name] = true;
	end
	
	self:clearBlocks();
	tempSpawn = self.activeSpawn;
	
	
	self:new();
	
	if tempSpawn and tempSpawn ~= "" then
		self.activeSpawn = tempSpawn;
	end
	
	if not self.data.maps[levelId] then 
		levelId = self.activeMap;
	end
	
	self.activeMap = levelId;

	for k, block in pairs(self.data.maps[self.activeMap].blocks) do
		self:appendBlock(block.x, block.y, block.w, block.h, block.color, block.entityType);
	end	
	
	for k, block in pairs(self.data.maps[self.activeMap].hazards) do
		self:appendHazard(block.x, block.y, block.w, block.h);
	end	
	
	for k, block in pairs(self.data.maps[self.activeMap].portals) do
		self:appendPortal(block.x, block.y, block.w, block.h, block.spawn);
	end			
	
	for k, block in pairs(self.data.maps[self.activeMap].checkpoints) do
		self:appendCheckpoint(block.x, block.y, block.w, block.h, block.spawn);
	end		
	
	for k, block in pairs(self.data.maps[self.activeMap].decorations) do
		self:appendDecoration(block.x, block.y, block.w, block.h, block.color, block.type, block.value);
	end		
	
	for k, block in pairs(self.data.maps[self.activeMap].items) do
		if ((not self.itemList[self.activeMap]) or (self.itemList[self.activeMap] and self.itemList[self.activeMap][k])) then 
			self:appendItem(block.x, block.y, block.w, block.h, block.entityType, k);
		end
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
	static.isLoading = false;
end

function level:appendBlock(x, y, width, height, color, type)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	if not color then color = {1, 1, 1} end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.x = layout.getX(x); 
	block.y = layout.getY(y); 
	-- because misha is gay
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.color = color;
	block.type = type;
	
	block.body = love.physics.newBody(world, block.x, block.y, "static");
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
	block.x = layout.getX(x); 
	block.y = layout.getY(y); 
	-- because misha is gay
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	--block.type = level.blockNameList.hazard;
	
	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	block.fixture:setSensor(true);
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
	block.x = layout.getX(x); 
	block.y = layout.getY(y); 
	-- because misha is gay
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.color = {1,1,1};
	block.spawn = spawn;
	--block.type = level.blockNameList.portal;
	
	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	if block.spawn and block.spawn ~= "" then
		block.fixture:setSensor(true);
	end
	table.insert(self.portals, block);
end

function level:appendCheckpoint(x, y, width, height, spawn)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.x = layout.getX(x); 
	block.y = layout.getY(y); 
	-- because misha is gay
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.spawn = spawn;
	--block.type = level.blockNameList.checkpoint;
	
	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	if block.spawn and block.spawn ~= "" then
		block.fixture:setSensor(true);
	end
	table.insert(self.checkpoints, block);
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

function level:appendItem(x, y, width, height, type, name)
	if not x then x = 0 end;
	if not y then y = 0 end;
	
	local block = {};

	block.width = layout.getX(50);
	block.height = layout.getY(50);
	
	block.x = layout.getX(x + width * 0.5); 
	block.y = layout.getY(y + height); 
	
	block.name = name;

	block.color = {1,1,1};
	block.type = type;
	if (block.type == level.blockNameList.itemDash) then
		block.picture = graphics.abilities.dash;
	elseif (block.type == level.blockNameList.itemDoubleJump) then
		block.picture = graphics.abilities.jump;
	elseif (block.type == level.blockNameList.itemWallClimb) then
		block.picture = graphics.abilities.wallclimb;
	else
		block.picture = graphics.default;
	end
	
	block.value = value;
	block.randomSeed = love.math.random() * 100;
	
	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setSensor(true);
	
	table.insert(self.items, block);
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
	for k, block in pairs(self.checkpoints) do
		block.body:destroy();
	end
	for k, block in pairs(self.items) do
		block.body:destroy();
	end
	self.blocks = {};
	self.portals = {};
	self.hazards = {};
	self.decorations = {};
	self.checkpoints = {};
	self.items = {};
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
		love.graphics.setColor({1, math.sin(love.timer.getTime() * 10) * 0.5 + 0.5, 0.1});
		for k, v in ipairs(self.hazards) do
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
		
		for k, v in ipairs(self.portals) do
			love.graphics.setColor(v.color)
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
		
		for k, v in ipairs(self.items) do
			love.graphics.draw(
				v.picture.picture, 
				v.x - v.width * 0.5, 
				v.y + layout.getY(math.sin(love.timer.getTime() * 10 + v.randomSeed) * 2) - v.height * 0.5, 
				0, 
				layout.getX(v.width/v.picture.picture:getWidth()), 
				layout.getY(v.height/v.picture.picture:getHeight())
			);
		end
		
		if (self.portal) then
			love.graphics.setColor(self.portal.color)
			love.graphics.polygon("fill", self.portal.body:getWorldPoints(self.portal.shape:getPoints()))
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