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
    button = "Button",
    door = "Door",
    -- item section
	item = "Item",
	itemGun = "Gun",
	itemDash = "Dash",
	itemDoubleJump = "Doublejump",
	itemWallClimb = "Walljump"
};
level.mapDiff = {};
level.lastPortalPass = -1;
level.lastPortalPassTimer = 2;

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
            buttons = {},
            doors = {},
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
    self.buttons = {};
    self.doors = {};
	self.activeSpawn = self.data.activeSpawn;

    if not self.activeSpawn or self.activeSpawn == '' then
        for indexMap, valueMap in pairs(self.data.maps) do
            for indexSpawn, valueSpawn in pairs(valueMap.spawns) do
                self.activeSpawn = indexSpawn;
				break;
            end
        end
    end

    if not self.activeSpawn or self.activeSpawn == '' then
        error('Map doesn\'t contain any spawn points');
    end

	self:clearBlocks();
end

function level:goToSpawn(spawnName, force)
	if (spawnName and (spawnName ~= "")) then
		map, pureSpawn = level:parseBlockName(spawnName);
		if (map == self.activeMap and not force) then
			for k, block in pairs(self.data.maps[self.activeMap].spawns) do
				if (spawnName == k) then
					player:teleport(layout.getX(block.x), layout.getY(block.y));
					break;
				end
			end
		elseif force or (love.timer.getTime() > self.lastPortalPass + self.lastPortalPassTimer) then
			static.isLoading = true;
			if force then
				love.graphics.clear(1, 0, 0);
				love.graphics.present();
				love.graphics.clear(1, 0, 0);
				love.graphics.present();
				love.graphics.clear(1, 0, 0);
				love.timer.sleep(0.5);
			else
				love.graphics.clear(0, 0, 0);
				love.graphics.present();
				love.graphics.clear(0, 0, 0);
				love.graphics.present();
				love.graphics.clear(0, 0, 0);
			end
			level:changeLevel(map, spawnName);
			--[[if (force) then
				self.lastPortalPass = -1;
			end]]
		end
	end
end

function level:changeLevel(levelId, spawnId)
	love.graphics.present();
	
	camera.offsetX = 0;
	camera.offsetY = 0;

	if self.activeMap then --and (not self.itemList[self.activeMap])) then
		self.mapDiff[self.activeMap] = {};
		self.mapDiff[self.activeMap].items = {};
		self.mapDiff[self.activeMap].breakables = {};
	end

	for k, v in pairs(self.items) do
		self.mapDiff[self.activeMap].items[k] = true;
	end

	for k, v in pairs(self.blocks) do
		if (v.type == self.blockNameList.blockBreakable) then
			self.mapDiff[self.activeMap].breakables[k] = true;
		end
	end

	self:clearBlocks();
	tempSpawn = self.activeSpawn;

	--self:new();

	if tempSpawn and tempSpawn ~= "" then
		self.activeSpawn = tempSpawn;
	end

	if not self.data.maps[levelId] then
		levelId = self.activeMap;
	end

	self.activeMap = levelId;

	for k, block in pairs(self.data.maps[self.activeMap].blocks) do
		if (block.entityType == self.blockNameList.blockBreakable) then
			if ((not self.mapDiff[self.activeMap]) or (self.mapDiff[self.activeMap] and self.mapDiff[self.activeMap].breakables[k])) then
				self:appendBlock(k, block.x, block.y, block.w, block.h, block.color, block.entityType);
			end
		else
			self:appendBlock(k, block.x, block.y, block.w, block.h, block.color, block.entityType);
		end
	end

	for k, block in pairs(self.data.maps[self.activeMap].hazards) do
		self:appendHazard(k, block.x, block.y, block.w, block.h);
	end

	for k, block in pairs(self.data.maps[self.activeMap].portals) do
		self:appendPortal(k, block.x, block.y, block.w, block.h, block.spawn);
	end

	for k, block in pairs(self.data.maps[self.activeMap].checkpoints) do
		self:appendCheckpoint(k, block.x, block.y, block.w, block.h, block.spawn);
	end

	for k, block in pairs(self.data.maps[self.activeMap].decorations) do
		self:appendDecoration(k, block.x, block.y, block.w, block.h, block.color, block.type, block.value);
	end

	for k, block in pairs(self.data.maps[self.activeMap].items) do
		if ((not self.mapDiff[self.activeMap]) or (self.mapDiff[self.activeMap] and self.mapDiff[self.activeMap].items[k])) then
			self:appendItem(k, block.x, block.y, block.w, block.h, block.entityType, k);
		end
	end

	for k, block in pairs(self.data.maps[self.activeMap].doors) do
		self:appendDoor(k, block.x, block.y, block.w, block.h, block.color, block.entityType);
	end

	for k, block in pairs(self.data.maps[self.activeMap].buttons) do
		self:appendButton(k, block.x, block.y, block.w, block.h, block.links);
	end

	for k, block in pairs(self.data.maps[self.activeMap].checkpoints) do
		self:appendCheckpoint(k, block.x, block.y, block.w, block.h, block.spawn);
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

    self:appendBlock("topwall", 0, -1, self.data.maps[self.activeMap].sizeX * layout.w, 1); --top
    self:appendBlock("bottomwall", 0, self.data.maps[self.activeMap].sizeY * layout.h, self.data.maps[self.activeMap].sizeX * layout.w, 1); -- bottom
    self:appendBlock("leftwall", -1, 0, 1, self.data.maps[self.activeMap].sizeY * layout.h); -- left
    self:appendBlock("rightwall", self.data.maps[self.activeMap].sizeX * layout.w, 0, 1, self.data.maps[self.activeMap].sizeY * layout.h); -- right
	static.isLoading = false;
	self.lastPortalPass = love.timer.getTime();
end

function level:appendBlock(name, x, y, width, height, color, type)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	if not color then color = {1, 1, 1} end;
	type = type or "Solid";

	local block = {};
	block.width = layout.getX(width);
	block.height = layout.getY(height);
	block.x = layout.getX(x);
	block.y = layout.getY(y);
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.color = color;
	block.type = type;
	if (type == level.blockNameList.blockBreakable) then
		block.health = 10;
		block.healthMax = 10;
		block.picture = graphics.blocks.breakable.picture;
		block.picture2 = graphics.blocks.breakable.picture2;
	end

	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	block.fixture:setUserData(name .. " " .. block.type);
	self.blocks[name] = block;
end

function level:appendHazard(name, x, y, width, height)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;

	local block = {};
	block.width = layout.getX(width);
	block.height = layout.getY(height);
	block.x = layout.getX(x);
	block.y = layout.getY(y);
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	--block.type = level.blockNameList.hazard;

	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setUserData("hazard");
	block.fixture:setFriction(0.99);
	block.fixture:setSensor(true);
	self.hazards[name] = block;
end

function level:appendPortal(name, x, y, width, height, spawn)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;

	local block = {};
	block.width = layout.getX(width);
	block.height = layout.getY(height);
	block.x = layout.getX(x);
	block.y = layout.getY(y);
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.color = {1,1,1};
	block.spawn = spawn;
	--block.type = level.blockNameList.portal;

	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setUserData("portal");
	block.fixture:setFriction(0.99);
	if block.spawn and block.spawn ~= "" then
		block.fixture:setSensor(true);
	end
	self.portals[name] = block;
end

function level:appendSpawn(name, x, y, width, height, spawn)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;

	local block = {};
	block.width = layout.getX(width);
	block.height = layout.getY(height);
	block.x = layout.getX(x);
	block.y = layout.getY(y);
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.color = {1,1,1};
end

function level:appendCheckpoint(name, x, y, width, height, spawn)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;

	local block = {};
	block.width = layout.getX(width);
	block.height = layout.getY(height);
	block.x = layout.getX(x);
	block.y = layout.getY(y);
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.spawn = spawn;
	--block.type = level.blockNameList.checkpoint;

	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setUserData("checkpoint");
	block.fixture:setFriction(0.99);
	if block.spawn and block.spawn ~= "" then
		block.fixture:setSensor(true);
	end
	self.checkpoints[name] = block;
end

function level:appendButton(name, x, y, width, height, links)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;

	local block = {};
	block.width = layout.getX(width);
	block.height = layout.getY(height);
	block.x = layout.getX(x);
	block.y = layout.getY(y);
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.links = links;
	--block.type = level.blockNameList.checkpoint;

	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setUserData("button");
	block.fixture:setSensor(true);

	self.buttons[name] = block;
end

function level:appendDoor(name, x, y, width, height, color, defaultState)
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
	block.x = block.x + block.width * 0.5;
	block.y = block.y + block.height * 0.5;
	block.color = color;
	block.defaultState = defaultState;
	block.state = false;
	block.previousState = false;
	block.networkState = false;

	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	block.fixture:setUserData(name);
	self.doors[name] = block;
end

function level:appendDecoration(name, x, y, width, height, color, type, value)
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
	self.decorations[name] = block;
end

function level:appendItem(name, x, y, width, height, type, name)
	if not x then x = 0 end;
	if not y then y = 0 end;

	local block = {};

	block.width = layout.getX(50);
	block.height = layout.getY(50);

	block.x = layout.getX(x + width * 0.5);
	block.y = layout.getY(y + height * 0.5);

	block.name = name;

	block.color = {1,1,1};
	block.type = type;
	if (block.type == level.blockNameList.itemDash) then
		block.picture = graphics.abilities.dash;
	elseif (block.type == level.blockNameList.itemDoubleJump) then
		block.picture = graphics.abilities.jump;
	elseif (block.type == level.blockNameList.itemWallClimb) then
		block.picture = graphics.abilities.wallclimb;
	elseif (block.type == level.blockNameList.itemGun) then
		block.picture = graphics.abilities.gun;
	else
		block.picture = graphics.default;
	end

	block.value = value;
	block.randomSeed = love.math.random() * 100;

	block.body = love.physics.newBody(world, block.x, block.y, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setSensor(true);
	block.fixture:setUserData("item");

	self.items[name] = block;
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
	for k, block in pairs(self.buttons) do
		block.body:destroy();
	end
	for k, block in pairs(self.doors) do
		block.body:destroy();
	end
	self.blocks = {};
	self.portals = {};
	self.hazards = {};
	self.decorations = {};
	self.checkpoints = {};
	self.items = {};
	self.spawns = {};
    self.doors = {};
    self.buttons = {};
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

function level:update(dt)
	for k, v in pairs(self.blocks) do
		if (v.health and v.health <= 0) then
			v.body:destroy();
		end

		if (v.body:isDestroyed()) then
			self.blocks[k] = nil;
		end
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

		for k, v in pairs(self.blocks) do
			if not v.body:isDestroyed() then
				love.graphics.setColor(v.color)
				love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
				if (v.type == self.blockNameList.blockBreakable) then
					love.graphics.setColor(1 - v.color[1], 1 - v.color[2], 1 - v.color[3], 1 - v.health / (v.healthMax * 1.1 + 1))
					if v.health / (v.healthMax + 1) > 0.5 then
						love.graphics.draw(v.picture, v.x - v.width * 0.5, v.y - v.height * 0.5, 0, v.width / v.picture:getWidth(), v.height / v.picture:getHeight())
					else
						love.graphics.draw(v.picture2, v.x - v.width * 0.5, v.y - v.height * 0.5, 0, v.width / v.picture2:getWidth(), v.height / v.picture2:getHeight())
					end
				end
			end
		end
		love.graphics.setColor({1, math.sin(love.timer.getTime() * 6) * 0.5 + 0.5, 0.1});
		for k, v in pairs(self.hazards) do
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end

		for k, v in pairs(self.doors) do
			if v.state or v.networkState then
				love.graphics.setColor(v.color[1], v.color[2], v.color[3], 0.1);
			else
				love.graphics.setColor(v.color)
			end
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end

		for k, v in pairs(self.buttons) do
			love.graphics.setColor(0, 0, 0, 0.5);
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end

		for k, v in pairs(self.spawns) do
			love.graphics.rectangle("fill", v.x, v.y, 50, 50)
		end


		for k, v in pairs(self.portals) do
			love.graphics.setColor(v.color)
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end

		for k, v in pairs(self.items) do
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

				if network.currentMap and k == network.currentMap then
					love.graphics.setColor(1, 1, 1);
					love.graphics.line(
							map.x + map.w * 0.5,
							map.y,
							map.x + map.w * 0.5,
							map.y + map.h
					);
					love.graphics.line(
							map.x,
							map.y + map.h * 0.5,
							map.x + map.w,
							map.y + map.h * 0.5
					);
				end
			end
		end
	end
end