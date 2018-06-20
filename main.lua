love.window.setMode( 0, 0, {
	fullscreen = true,
	msaa = 2,
});

sw, sh = love.graphics.getDimensions();

layout = {
	w = 1366, 
	h = 768
}
function layout.getX(x)
	return sw * x / layout.w
end
function layout.getY(x)
	return sh * x / layout.h
end

function math.sign(x)
	return x > 0 and 1 or x < 0 and -1 or 0;
end

function math.between(x, a, b)
	if x > a and x < b then return true else return false end;
end;

keyboardEvent = {
	doublePressDuration = 0.2;
	leftKeyTimer = 0;
	rightKeyTimer = 0;
};

require("player");

level = {};

function level:new()
	level.blocks = {};
	level.goal = {}
	
	level.maps = {
		[0] = {
			[0] = {-50, 300, 600, 50, {0, 0, 1}},
			[1] = {300, 250, 100, 50, {0.5, 0.5, 1}},
			[2] = {600, 250, 50, 500, {0.5, 0.0, 0}},
			[3] = {900, 250, 100, 50, {0.5, 0.5, 1}},
			[4] = {1250, 300, 600, 50, {0.0, 0.5, 0}},
			["target"] = {1300, 225}
		},
	}
end

function level:changeLevel(levelNumber)
	level.blocks = {};
	self:appendBlock(sw * 0.5, 0, sw, 1); --top
	self:appendBlock(sw * 0.5, sh, sw, 1); -- bottom
	self:appendBlock(0, sh * 0.5, 1, sh);
	self:appendBlock(sw, sh * 0.5, 1, sh);
	
	if self.maps[levelNumber] then
		for k, v in ipairs(self.maps[levelNumber]) do
			if k ~= "target" then
				self:appendBlock(v);
			end
		end
	end
	
	self:makeTarget(self.maps[levelNumber]["target"][0], self.maps[levelNumber]["target"][1]);
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

function level:makeTarget(x, y)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 50 end;
	if not height then height = 100 end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.startX = layout.getX(x); 
	block.startY = layout.getY(y); 
	block.color = {255, 255, 255};
	block.body = love.physics.newBody(world, block.startX, block.startY, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	self.target = block;
end




function love.load()
	world = love.physics.newWorld(0, 9.8 * 2 * love.physics.getMeter())
	player:new();
	
	level:new();
	level:changeLevel(0);
end

function love.draw()
	if (player.isLeftDash or player.isRightDash) then 
		love.graphics.setColor(255,0,255);
	else
		love.graphics.setColor(255,0,0);
	end
		
	love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
	
	if (player.isLeftWallClimb) then
		love.graphics.rectangle("fill", player.body:getX(), player.body:getY()-player.height * 0.2, player.width, player.height * 0.3);
	elseif (player.isRightWallClimb) then
		love.graphics.rectangle("fill", player.body:getX(), player.body:getY()-player.height * 0.2, -player.width, player.height * 0.3);
	end

	love.graphics.setColor(1,1,1)
	love.graphics.draw(player.particleEmitter, player.body:getX(), player.body:getY() + player.height * 0.5)
	
	for k, v in ipairs(level.blocks) do
		love.graphics.setColor(v.color)
		love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
	end
	
	if (level.target) then
		love.graphics.setColor(level.target.color)
		love.graphics.polygon("fill", level.target.body:getWorldPoints(level.target.shape:getPoints()))
	end
	
	love.graphics.setColor(1,1,1)
	if (player.jumpAmount > 0) then
		love.graphics.print("*", 10, 10);
	end
	
	if player.body:isTouching(level.target.body) then
		love.graphics.print("CONGRATULATIONS! YOU ARE WIENER!", sw * 0.5 - 140, sh * 0.5);
	end
end

function love.keypressed(key)
	if key == 'space' then
		player.isJump = true;
	elseif key == "a" then
		if not player.isLeftDash then
			if love.timer.getTime() < keyboardEvent.leftKeyTimer + keyboardEvent.doublePressDuration and player.isDashAvailable and not player.isLeftWallClimb then
				player.isLeftDash = true;
				player.dashTimer = love.timer.getTime();
			else
				keyboardEvent.leftKeyTimer = love.timer.getTime();
			end
		end
	elseif key == "d" then
		if not player.isRightDash then
			if love.timer.getTime() < keyboardEvent.leftKeyTimer + keyboardEvent.doublePressDuration and player.isDashAvailable and not player.isRightWallClimb then
				player.isRightDash = true;
				player.dashTimer = love.timer.getTime();
			else
				keyboardEvent.leftKeyTimer = love.timer.getTime();
			end
		end
	end
end

function love.keyreleased( key )
   if key == "space" then
		player.isJump = false;
   end
end


function love.update(dt)
	if love.keyboard.isDown("lshift") then
		player.isSprint = true;
	else 
		player.isSprint = false;
	end
	
	if love.keyboard.isDown("a") then
		player.isMoveLeft = true;
	else 
		player.isMoveLeft = false;
	end
	
	if love.keyboard.isDown("d") then
		player.isMoveRight = true;
	else 
		player.isMoveRight = false;
	end
	
	player:move(dt);
	
	if player.body:getY() > sh + 50 then
		player:respawn();
	end
		
	world:update(dt)
end