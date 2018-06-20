level = {};

level.maps = {
	[0] = {
		blocks = {
			{x = -50,  y = 300, w = 600, h = 50,  color = {0, 0, 1}},
			{x = 300,  y = 250, w = 100, h = 50,  color = {0.5, 0.5, 1}},
			{x = 600,  y = 250, w = 50,  h = 500, color = {0.5, 0.0, 0}},
			{x = 900,  y = 250, w = 100, h = 50,  color = {0.5, 0.5, 1}},
			{x = 1250, y = 300, w = 600, h = 50,  color = {0.0, 0.5, 0}},
		},
		["target"] = {x = 1300, y = 225, nextMap = "another"}
	},
	["another"] = {
		blocks = {
			{x = 50,   y = 300, w = 600, h = 50,  color = {0, 0, 1}},
			{x = 0,    y = 250, w = 100, h = 50,  color = {0.5, 0.5, 1}},
			{x = 250,  y = 100, w = 50,  h = 500, color = {0.5, 0.0, 0}},
			{x = 900,  y = 250, w = 100, h = 50,  color = {0.5, 0.5, 1}},
			{x = 1250, y = 300, w = 600, h = 50,  color = {0.0, 0.5, 0}},
		},
		["target"] = {x = 1300, y = 225, nextMap = "someNextLevel"}
	},
}

function level:new()
	self.blocks = {};
	self.goal = {}
	self.target = {}
end

function level:changeLevel(lid)
	level:new()
	player:respawn()
	if not self.maps[lid] then lid = 0 end
	for k, v in pairs(self.maps[lid].blocks) do
		self:appendBlock(v.x, v.y, v.w, v.h, v.color)
		--self.blocks[blockId].color = {block.color.r, block.color.g, block.color.b}
	end

	self:appendBlock(layout.w * 0.5, -0.5, layout.w, 1); --top
	self:appendBlock(layout.w * 0.5, layout.h + 0.5, layout.w, 1); -- bottom
	self:appendBlock(-0.5, layout.h * 0.5, 1, layout.h);
	self:appendBlock(layout.w + 0.5, layout.h * 0.5, 1, layout.h);

	self:makeTarget(self.maps[lid]["target"].x, self.maps[lid]["target"].y, self.maps[lid]["target"].nextMap);
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
	block.color = color;
	block.body = love.physics.newBody(world, block.startX, block.startY, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	table.insert(self.blocks, block);
end

function level:makeTarget(x, y, nextMap)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 50 end;
	if not height then height = 100 end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.startX = layout.getX(x); 
	block.startY = layout.getY(y); 
	block.nextMap = nextMap
	block.color = {255, 255, 255};
	block.body = love.physics.newBody(world, block.startX, block.startY, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	self.target = block;
end

function level:draw()
	for k, v in ipairs(self.blocks) do
		love.graphics.setColor(v.color)
		love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
	end
	
	if (self.target) then
		love.graphics.setColor(self.target.color)
		love.graphics.polygon("fill", self.target.body:getWorldPoints(self.target.shape:getPoints()))
	end
end