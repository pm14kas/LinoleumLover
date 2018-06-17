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

require("player");

level = {};
function level:appendBlock(x, y, width, height, color)
	if not x then x = 0 end;
	if not y then y = 0 end;
	if not width then width = 0 end;
	if not height then height = 0 end;
	if not color then color = {0, 0, 0} end;
	if #color ~= 3 then color = {0, 0, 0} end;
	
	local block = {};
	block.width = layout.getX(width); 
	block.height = layout.getY(height); 
	block.startX = layout.getX(x); 
	block.startY = layout.getY(y); 
	block.color = color; --{color[0], color[1], color[2]};
	block.body = love.physics.newBody(world, block.startX, block.startY, "static");
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setFriction(0.99);
	table.insert(self, block);
end


function love.load()
	world = love.physics.newWorld(0, 9.8 * 2 * love.physics.getMeter())
	player:new();
	
	level:appendBlock(sw * 0.5, 0, sw, 1); --top
	--level:appendBlock(sw * 0.5, sh, sw, 1); -- bottom
	level:appendBlock(0, sh * 0.5, 1, sh);
	level:appendBlock(sw, sh * 0.5, 1, sh);

	level:appendBlock(-50, 300, 600, 50, {0, 0, 1});
	level:appendBlock(300, 250, 100, 50, {0.5, 0.5, 1});
	level:appendBlock(600, 250, 50, 500, {0.5, 0.0, 0});
	
	level:appendBlock(900, 250, 100, 50, {0.5, 0.5, 1});
	level:appendBlock(1250, 300, 600, 50, {0.0, 0.5, 0});
	

end

function love.draw()
	love.graphics.setColor(255,0,0)
	love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
	
	if (player.isLeftWallClimb) then
		love.graphics.rectangle("fill", player.body:getX(), player.body:getY()-player.height * 0.2, player.width, player.height * 0.3);
	elseif (player.isRightWallClimb) then
		love.graphics.rectangle("fill", player.body:getX(), player.body:getY()-player.height * 0.2, -player.width, player.height * 0.3);
	end
	
	for k, v in ipairs(level) do
		love.graphics.setColor(v.color)
		love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
	end
	
	love.graphics.setColor(1,1,1)
	if (player.jumpAmount > 0) then
		love.graphics.print("*", 10, 10);
	end
	
	if math.between(player.body:getX(), layout.getX(1150), layout.getY(2000)) and math.between(player.body:getY(), layout.getX(200), layout.getY(500)) then
		love.graphics.print("CONGRATULATIONS! YOU ARE WIENER!", sw * 0.5 - 140, sh * 0.5);
	end
end

function love.keypressed(key)
	if key == 'space' then
		player.isJump = true;
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

	if love.keyboard.isDown("w") or love.keyboard.isDown("space") then
		--player.isJump = true;
	else
		--player.isJump = false;
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
	
	player:move();
	
	if player.body:getY() > sh + 50 then
		player:respawn();
	end
		
	world:update(dt)
end