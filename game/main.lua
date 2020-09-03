love.window.setMode(0, 0, {
	--fullscreen = true,
	--msaa = 2,
});

static = {
	isLoading = false
};

mistralFont = love.graphics.newFont("fonts/mistral.ttf", 1000)
graphikFont = love.graphics.newFont("fonts/GraphikRegular.ttf", 1000);
love.graphics.setFont(graphikFont);

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
function layout.invertX(x)
	return x * layout.w / sw;
end
function layout.invertY(y)
	return y * layout.h / sh;
end

keyboardEvent = {
	doublePressDuration = 0.25;
	leftKeyTimer = 0;
	rightKeyTimer = 0;
};

graphics = {
	abilities = {
		dash = {
			picture = love.graphics.newImage("graphics/icons/icon_dash.png")
		},
		jump = {
			picture = love.graphics.newImage("graphics/icons/icon_jump_double.png")
		},
		wallclimb = {
			picture = love.graphics.newImage("graphics/icons/icon_wall_climb.png")
		},
		gun = {
			picture = love.graphics.newImage("graphics/icons/icon_gun.png")
		}
	},
	hud = {
		dash = {
			picture = love.graphics.newImage("graphics/icons/icon_dash_text.png")
		},
		jump = {
			picture = love.graphics.newImage("graphics/icons/icon_jump_text.png")
		},
		gun = {
			picture = love.graphics.newImage("graphics/icons/icon_gun.png")
		}	
	},
	blocks = {
		breakable = {
			picture = love.graphics.newImage("graphics/images/cracks.png")
		}
	},
	default = {
		picture = love.graphics.newImage("graphics/icons/icon_404.png")	
	}
}

require("json.json");
require("functions");
require("animation");
require("player");
require("level");
require("network");

function beginContact(a, b, coll)
	if (a:getUserData() == "bulletUser") then
		local ids = splitString(b:getUserData(), " ");
		if (b:getUserData() == "player") then
			a:getBody():destroy();
		elseif (b:getUserData() == "bulletUser") then
		elseif((#ids == 2) and ids[2] == level.blockNameList.blockBreakable) then
			damage(level.blocks[ids[1]], 1);
			a:getBody():destroy();
		else
			a:getBody():destroy();
		end
	end

	if (b:getUserData() == "bulletUser") then
		local ids = splitString(a:getUserData(), " ");
		if (a:getUserData() == "player") then
			b:getBody():destroy();
		elseif (a:getUserData() == "bulletUser") then
		elseif((#ids == 2) and ids[2] == level.blockNameList.blockBreakable) then
			damage(level.blocks[ids[1]], 1);
			b:getBody():destroy();
		else
			b:getBody():destroy();
		end
	end
end
 
function endContact(a, b, coll)
end
 
function preSolve(a, b, coll)
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function damage(item, amount)
	if (item.health ~= nil) then
		item.health = item.health - amount;
		return true;
	else
		return false;
	end
end

function love.load()
	world = love.physics.newWorld(0, 9.8 * 2 * love.physics.getMeter())
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	player:new();

	level:new();
	level:goToSpawn(level.activeSpawn);
end

function love.draw()
	if static.isLoading then 
		return;
	end
	
	level:draw()
	if viewMode then
		network:draw()
		player:draw()
	end
	love.graphics.setColor(1,1,1)
	local iconShift = 0;
	for i = 1, player.jumpAmount do
		--love.graphics.print("*", 10, 10);
		love.graphics.draw(
			graphics.hud.jump.picture, 
			layout.getX(10 + (i-1) * 40), 
			layout.getY(10), 
			0, 
			layout.getX(50/graphics.abilities.jump.picture:getWidth()), 
			layout.getY(50/graphics.abilities.jump.picture:getHeight())
		);
		iconShift = iconShift + 1;
	end
	
	if player.isDashAvailable then
		--love.graphics.print(">", 50, 10, 0, 0.5, 0.5);
		love.graphics.draw(
			graphics.hud.dash.picture, 
			layout.getX(10 + iconShift * 50), 
			layout.getY(10), 
			0, 
			layout.getX(50/graphics.abilities.jump.picture:getWidth()), 
			layout.getY(50/graphics.abilities.jump.picture:getHeight())
		);
		iconShift = iconShift + 1;
	end
	
	if player.isShootingEnabled then
		--love.graphics.print(">", 50, 10, 0, 0.5, 0.5);
		love.graphics.draw(
			graphics.hud.gun.picture, 
			layout.getX(10 + iconShift * 50), 
			layout.getY(10), 
			0, 
			layout.getX(50/graphics.abilities.jump.picture:getWidth()), 
			layout.getY(50/graphics.abilities.jump.picture:getHeight())
		);
		
		iconShift = iconShift + 1;
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
				if love.timer.getTime() < keyboardEvent.rightKeyTimer + keyboardEvent.doublePressDuration and player.isDashAvailable and not player.isRightWallClimb then
					player.isRightDash = true;
					player.dashTimer = love.timer.getTime();
				else
					keyboardEvent.rightKeyTimer = love.timer.getTime();
				end
			end
		elseif key == "x" then
			player:keyboardShoot();
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
	network:update(dt)
	player:update(dt)
	level:update(dt)
	world:update(dt)
end