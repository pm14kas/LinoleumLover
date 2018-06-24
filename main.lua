love.window.setMode(0, 0, {
	--fullscreen = true,
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

keyboardEvent = {
	doublePressDuration = 0.2;
	leftKeyTimer = 0;
	rightKeyTimer = 0;
};

require("functions");
require("player");
require("level");
function love.load()
	world = love.physics.newWorld(0, 9.8 * 2 * love.physics.getMeter())
	player:new();
	
	level:new();
	level:changeLevel(0);
end

function love.draw()
	player:draw()
	level:draw()
	
	love.graphics.setColor(1,1,1)
	if (player.jumpAmount > 0) then
		love.graphics.print("*", 10, 10);
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
	player:update(dt)
	world:update(dt)
end