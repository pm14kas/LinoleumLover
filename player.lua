player = {};
function player:new(x, y)
	if (x == nil) then
		x = 50;
	end

	if (y == nil) then
		y = 50;
	end
	
	self.width = layout.getX(50);
	self.height = layout.getY(100);
	self.startX = layout.getX(x);
	self.startY = layout.getY(y);
	self.speedX = layout.getX(10);
	self.speedXSprint = layout.getX(190 * love.physics.getMeter());
	self.speedXRegular = layout.getX(300 * love.physics.getMeter());
	self.speedXMax = layout.getX(10 * love.physics.getMeter());
	self.jumpImpulse = 0.5 * self.width * self.height;
	self.dashSpeed = layout.getX(90 * love.physics.getMeter());
	self.dashDuration = 0.1;
	self.dashTimer = 0;

	self.isSprint = false;
	self.isMoveLeft = false;
	self.isMoveRight = false;
	self.isJump = false;
	self.isStand = false;
	self.isLeftWallClimb = false;
	self.isRightWallClimb = false;
	self.isLeftDash = false;
	self.isRightDash = false;
	self.isDashAvailable = false;

	self.speedWallClimb = layout.getY(5) * love.physics.getMeter();
	self.jumpAmount = 0;
	self.jumpAmountMax = 1;
	
	self.body = love.physics.newBody(world, self.startX, self.startY, "dynamic");
	self.body:setMass(100);
	self.body:setFixedRotation(true);
	self.shape = love.physics.newRectangleShape(self.width, self.height);
	self.fixture = love.physics.newFixture(self.body, self.shape);
	
	self.sprite = love.graphics.newImage("graphics/particle/sprite_doublejump.png");
	self.particleEmitter = love.graphics.newParticleSystem(self.sprite, 30);
	self.particleEmitter:setParticleLifetime(0.1, 0.5);
	self.particleEmitter:setSizes(0.3)
	self.particleEmitter:setLinearAcceleration(-5, 0, 5, 100 * love.physics.getMeter());
	self.particleEmitter:setEmissionArea("uniform", self.width * 0.4, 0, 0, true);
	self.particleEmitter:setColors(255, 255, 255, 255, 255, 255, 255, 0);
end

function player:respawn(spawnx, spawny)
	if ((self.body) and (not self.body:isDestroyed())) then
		self.body:destroy();
	end
	self:new(spawnx, spawny);
end

function player:teleport(x, y)
	vx, vy = self.body:getLinearVelocity();
	self.body:setPosition(x, y);
	self.body:setLinearVelocity(vx * 0.5, vy * 0.5);
end

function actualJump(fixture, x, y, xn, yn, fraction)
	if (player.isJump) then
		if player.isLeftWallClimb then
			player.body:setLinearVelocity(0, 0);
			player.body:applyLinearImpulse(player.jumpImpulse, -player.jumpImpulse)
			player.isJump = false;
		elseif player.isRightWallClimb then
			player.body:setLinearVelocity(0, 0);
			player.body:applyLinearImpulse(-player.jumpImpulse, -player.jumpImpulse)
			player.isJump = false;
		else
			local x, y = player.body:getLinearVelocity();
			player.body:setLinearVelocity(x, 0);
			player.body:applyLinearImpulse(0, -player.jumpImpulse)
			player.isJump = false;
		end
		player.isStand = false;
	end
	return 1
end


function IsStandCallback(fixture, x, y, xn, yn, fraction)
	player.jumpAmount = player.jumpAmountMax;
	player.isStand = true;
	player.isDashAvailable = true;
	return 1;
end

function jumpKeyPressed( key, scancode, isrepeat) 
	if key == "space" then
		player.isJump = true;
	end
end

function IsLeftWallClimbCallback(fixture, x, y, xn, yn, fraction)
	player.isLeftWallClimb = true;
	player.isDashAvailable = true;
	player.isJump = false;
	player.jumpAmount = player.jumpAmountMax;
	return 1;
end

function IsRightWallClimbCallback(fixture, x, y, xn, yn, fraction)
	player.isRightWallClimb = true;
	player.isDashAvailable = true;
	player.isJump = false;
	player.jumpAmount = player.jumpAmountMax;
	return 1;
end

function player:move(dt)
	if self.isSprint then
		self.speedX = self.speedXSprint;
	else 
		self.speedX = self.speedXRegular;
	end

	local rayCastDepth = 1;

	self.isStand = false;
	world:rayCast(self.body:getX() - self.width * 0.5, 
		self.body:getY() + self.height * 0.5, 
		self.body:getX() - self.width * 0.5, 
		self.body:getY() + self.height * 0.5 + rayCastDepth, 
		IsStandCallback
	);
	world:rayCast(self.body:getX() - self.width * 0.25, 
		self.body:getY() + self.height * 0.5, 
		self.body:getX() - self.width * 0.25, 
		self.body:getY() + self.height * 0.5 + rayCastDepth, 
		IsStandCallback
	);
	world:rayCast(self.body:getX(), 
		self.body:getY() + self.height * 0.5, 
		self.body:getX(), 
		self.body:getY() + self.height * 0.5 + rayCastDepth, 
		IsStandCallback
	);
	world:rayCast(self.body:getX() + self.width * 0.25, 
		self.body:getY() + self.height * 0.5, 
		self.body:getX() + self.width * 0.25, 
		self.body:getY() + self.height * 0.5 + rayCastDepth, 
		IsStandCallback
	);
	world:rayCast(self.body:getX() + self.width * 0.5, 
		self.body:getY() + self.height * 0.5, 
		self.body:getX() + self.width * 0.5, 
		self.body:getY() + self.height * 0.5 + rayCastDepth, 
		IsStandCallback
	);
	
	if self.isJump and not (self.isLeftDash or self.isRightDash) then
		if (self.isStand) then
			world:rayCast(self.body:getX() - self.width * 0.5, 
				self.body:getY() + self.height * 0.5, 
				self.body:getX() - self.width * 0.5, 
				self.body:getY() + self.height * 0.5 + rayCastDepth, 
				actualJump
			);
			world:rayCast(self.body:getX() - self.width * 0.25, 
				self.body:getY() + self.height * 0.5, 
				self.body:getX() - self.width * 0.25, 
				self.body:getY() + self.height * 0.5 + rayCastDepth, 
				actualJump
			);
			world:rayCast(self.body:getX(), 
				self.body:getY() + self.height * 0.5, 
				self.body:getX(), 
				self.body:getY() + self.height * 0.5 + rayCastDepth, 
				actualJump
			);
			world:rayCast(self.body:getX() + self.width * 0.25,
				self.body:getY() + self.height * 0.5, 
				self.body:getX() + self.width * 0.25, 
				self.body:getY() + self.height * 0.5 + rayCastDepth, 
				actualJump
			);
			world:rayCast(self.body:getX() + self.width * 0.5,
				self.body:getY() + self.height * 0.5, 
				self.body:getX() + self.width * 0.5, 
				self.body:getY() + self.height * 0.5 + rayCastDepth, 
				actualJump
			);
		elseif (self.jumpAmount > 0) then
			self.jumpAmount = self.jumpAmount - 1;
			if not (self.isLeftWallClimb or self.isRightWallClimb) then
				player.particleEmitter:emit(30);
			end
			actualJump()
		end
	end
	
	if self.isStand then
		self.isLeftWallClimb = false;
		self.isRightWallClimb = false;
	else
		self.isLeftWallClimb = false;
		world:rayCast(
			self.body:getX() - self.width * 0.5, 
			self.body:getY() - self.height * 0.5, 
			self.body:getX() - self.width * 0.5 - rayCastDepth, 
			self.body:getY() - self.height * 0.5, 
			IsLeftWallClimbCallback
		);
		world:rayCast(
			self.body:getX() - self.width * 0.5, 
			self.body:getY() - self.height * 0.25, 
			self.body:getX() - self.width * 0.5 - rayCastDepth, 
			self.body:getY() - self.height * 0.25, 
			IsLeftWallClimbCallback
		);
		world:rayCast(
			self.body:getX() - self.width * 0.5, 
			self.body:getY(), 
			self.body:getX() - self.width * 0.5 - rayCastDepth, 
			self.body:getY(), 
			IsLeftWallClimbCallback
		);
		world:rayCast(
			self.body:getX() - self.width * 0.5, 
			self.body:getY() + self.height * 0.25, 
			self.body:getX() - self.width * 0.5 - rayCastDepth, 
			self.body:getY() + self.height * 0.25, 
			IsLeftWallClimbCallback
		);
		world:rayCast(
			self.body:getX() - self.width * 0.5, 
			self.body:getY() + self.height * 0.5, 
			self.body:getX() - self.width * 0.5 - rayCastDepth, 
			self.body:getY() + self.height * 0.5, 
			IsLeftWallClimbCallback
		);
		
		self.isRightWallClimb = false;
		world:rayCast(
			self.body:getX() + self.width * 0.5, 
			self.body:getY() - self.height * 0.5, 
			self.body:getX() + self.width * 0.5 + rayCastDepth, 
			self.body:getY() - self.height * 0.5, 
			IsRightWallClimbCallback
		);
		world:rayCast(
			self.body:getX() + self.width * 0.5, 
			self.body:getY() - self.height * 0.25, 
			self.body:getX() + self.width * 0.5 + rayCastDepth, 
			self.body:getY() - self.height * 0.25, 
			IsRightWallClimbCallback
		);
		world:rayCast(
			self.body:getX() + self.width * 0.5, 
			self.body:getY(), 
			self.body:getX() + self.width * 0.5 + rayCastDepth, 
			self.body:getY(), 
			IsRightWallClimbCallback
		);
		world:rayCast(
			self.body:getX() + self.width * 0.5, 
			self.body:getY() + self.height * 0.25, 
			self.body:getX() + self.width * 0.5 + rayCastDepth, 
			self.body:getY() + self.height * 0.25, 
			IsRightWallClimbCallback
		);
		world:rayCast(
			self.body:getX() + self.width * 0.5, 
			self.body:getY() + self.height * 0.5, 
			self.body:getX() + self.width * 0.5 + rayCastDepth, 
			self.body:getY() + self.height * 0.5, 
			IsRightWallClimbCallback
		);
	end

	if self.isMoveLeft then
		self.body:applyForce(-self.speedX, 0)
	end
	if self.isMoveRight then
		self.body:applyForce(self.speedX, 0)
	end
	
	if self.isLeftDash and love.timer.getTime() < self.dashTimer + self.dashDuration and self.isDashAvailable then
		self.isDashAvailable = false;
		self.body:setLinearVelocity(-self.dashSpeed, 0);
		self.particleEmitter:emit(5);
		self.isLeftDash = true;
	elseif love.timer.getTime() > self.dashTimer + self.dashDuration and love.timer.getTime() < self.dashTimer + self.dashDuration * 1.5 then
		self.isLeftDash = false;
		self.body:setLinearVelocity(0, 0);
	end
	
	if self.isRightDash and love.timer.getTime() < self.dashTimer + self.dashDuration then
		self.isDashAvailable = false;
		self.body:setLinearVelocity(self.dashSpeed, 0);
		self.particleEmitter:emit(5);
		self.isRightDash = true;
	elseif love.timer.getTime() > self.dashTimer + self.dashDuration and love.timer.getTime() < self.dashTimer + self.dashDuration * 1.5 then
		self.isRightDash = false;
		self.body:setLinearVelocity(0, 0);
	end
	
	if not (self.isLeftDash or self.isRightDash) then
		local x, y = self.body:getLinearVelocity();
		if math.abs(x) > self.speedXMax then
			self.body:setLinearVelocity(self.speedXMax * math.sign(x), y);
		end
	end
	
	if (self.isRightWallClimb or self.isLeftWallClimb) then
		self.body:applyForce(0, self.speedWallClimb * 10);
	end
	
	self.particleEmitter:update(dt);
end

function player:update(dt)
	if love.keyboard.isDown("lshift") then
		self.isSprint = true;
	else 
		self.isSprint = false;
	end
	
	if love.keyboard.isDown("a") then
		self.isMoveLeft = true;
	else 
		self.isMoveLeft = false;
	end
	
	if love.keyboard.isDown("d") then
		self.isMoveRight = true;
	else 
		self.isMoveRight = false;
	end
	
	self:move(dt);
	
	if self.body:getY() > sh + 50 then
		self:respawn();
	end

	for k, v in ipairs(level.hazards) do
		if self.body and v.body and not self.body:isDestroyed() and not v.body:isDestroyed() and self.body:isTouching(v.body) then
			level:goToSpawn(level.activeSpawn, true);
			break;
		end
	end

	for k, v in ipairs(level.portals) do
		if self.body and v.body and not self.body:isDestroyed() and not v.body:isDestroyed() and self.body:isTouching(v.body) then
			if v.spawn then
				level:goToSpawn(v.spawn);
				break;
			end
		end
	end
	
end

function player:draw()
	if (self.isLeftDash or self.isRightDash) then 
		love.graphics.setColor(255,0,255);
	else
		love.graphics.setColor(255,0,0);
	end
		
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	
	if (self.isLeftWallClimb) then
		love.graphics.rectangle("fill", self.body:getX(), self.body:getY()-self.height * 0.2, self.width, self.height * 0.3);
	elseif (self.isRightWallClimb) then
		love.graphics.rectangle("fill", self.body:getX(), self.body:getY()-self.height * 0.2, -self.width, self.height * 0.3);
	end

	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.particleEmitter, self.body:getX(), self.body:getY() + self.height * 0.5)
end