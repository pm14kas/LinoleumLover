love.window.setMode(0, 0, {
	--fullscreen = true,
	--msaa = 2,
});

fontMistral = love.graphics.newFont("fonts/mistral.ttf", 100);
love.graphics.setFont(fontMistral);

love.window.setTitle("Linoleum");

sw, sh = love.graphics.getDimensions();
viewMode = true;

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
require("json.json");
require("functions");
require("player");
require("level");
function love.load()
	world = love.physics.newWorld(0, 9.8 * 2 * love.physics.getMeter())
	player:new();
	
	level:new();
	level:goToSpawn(level.activeSpawn);
end

function love.draw()
	level:draw()
	if viewMode then
		player:draw()
	end
	love.graphics.setColor(1,1,1)
	if (player.jumpAmount > 0) then
		love.graphics.print("*", 10, 10);
	end
end

function love.keypressed(key)
	if (viewMode) then
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
	if key == "m" then
		viewMode = not viewMode;
	end
end

function love.keyreleased( key )
	if viewMode then
		if key == "space" then
			player.isJump = false;
		end
   end
end

function love.update(dt)
	if viewMode then
		player:update(dt)
		world:update(dt)
	end
end