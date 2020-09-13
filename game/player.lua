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

	self.isSprint = t;
	self.isMoveLeft = false;
	self.isMoveRight = false;
	self.isJump = false;
	self.isStand = false;
	self.isLeftWallClimb = false;
	self.isRightWallClimb = false;
	self.isLeftDash = false;
	self.isRightDash = false;
	self.isDashAvailable = false;
	
	self.directionEnum = {left = 1, right = 2};
	self.direction = self.directionEnum.left -- true goes to left, false goes to right
	
	self.lastShotTimer = 0.0;
	self.lastShotTime = -1;
	self.bulletSpeed = layout.getX(50 * love.physics.getMeter());
	self.bulletLifetime = 10;
	self.bulletList = {};
	self.isShootingEnabled = false;
	self.isShootingAvailable = false;
	
	self.isWallClimbEnabled = false;
	self.isDashEnabled = false;

	self.speedWallClimb = layout.getY(5) * love.physics.getMeter();
	self.jumpAmount = 0;
	self.jumpAmountMax = 0; -- 1 stands for double jump
	
	self.body = love.physics.newBody(world, self.startX, self.startY, "dynamic");
	self.body:setMass(100);
	self.body:setFixedRotation(true);
	self.shape = love.physics.newRectangleShape(self.width, self.height);
	self.fixture = love.physics.newFixture(self.body, self.shape);
	self.fixture:setUserData("player");
	--self.fixture:setFriction(0.99);
	
	self.sprite = love.graphics.newImage("graphics/particle/sprite_doublejump.png");
	self.particleEmitter = love.graphics.newParticleSystem(self.sprite, 30);
	self.particleEmitter:setParticleLifetime(0.1, 0.5);
	self.particleEmitter:setSizes(0.3)
	self.particleEmitter:setLinearAcceleration(-5, 0, 5, 100 * love.physics.getMeter());
	self.particleEmitter:setEmissionArea("uniform", self.width * 0.4, 0, 0, true);
	self.particleEmitter:setColors(255, 255, 255, 255, 255, 255, 255, 0);
	
	self.animationWalkSprite = love.graphics.newImage("graphics/player/player_animation.png");
	self.animationWalk = animation:new("player_walk", {
		w = 128,
		h = 128,
		duration = 1,
		img = self.animationWalkSprite
	});
end

function player:respawn(spawnx, spawny)
	if ((self.body) and (not self.body:isDestroyed())) then
		self.body:destroy();
	end
	
	for k, v in ipairs(self.bulletList) do
		if (not v.body:isDestroyed()) then
			v.body:destroy();
		end
	end
	
	self.bulletList = {};
	
	isDashEnabled = self.isDashEnabled;
	isWallClimbEnabled = self.isWallClimbEnabled;
	isShootingEnabled = self.isShootingEnabled;
	jumpAmountMax = self.jumpAmountMax;
	
	direction = self.direction;
	
	self:new(spawnx, spawny);
	
	self.isDashEnabled = isDashEnabled;
	self.isWallClimbEnabled = isWallClimbEnabled;
	self.isShootingEnabled = isShootingEnabled;
	self.jumpAmountMax = jumpAmountMax;
	self.direction = direction;
	
end

function player:teleport(x, y)
	vx, vy = self.body:getLinearVelocity();
	self.body:setPosition(x, y);
	self.body:setLinearVelocity(vx * 0.5, vy * 0.5);
end

function player:actualJump()
	if (self.isJump) then
		if self.isLeftWallClimb then
			self.body:setLinearVelocity(0, 0);
			self.body:applyLinearImpulse(self.jumpImpulse, -self.jumpImpulse)
			self.isJump = false;
		elseif self.isRightWallClimb then
			self.body:setLinearVelocity(0, 0);
			self.body:applyLinearImpulse(-self.jumpImpulse, -self.jumpImpulse)
			self.isJump = false;
		else
			local x, y = self.body:getLinearVelocity();
			self.body:setLinearVelocity(x, 0);
			self.body:applyLinearImpulse(0, -self.jumpImpulse)
			self.isJump = false;
		end
		self.isStand = false;
	end
end


function IsStandCallback(fixture, x, y, xn, yn, fraction)
	if fixture:isSensor() then
		return -1;
	else
		player.jumpAmount = player.jumpAmountMax;
		player.isStand = true;
		player.isDashAvailable = true;
		return 0;
	end
end

function jumpKeyPressed( key, scancode, isrepeat) 
	if key == "space" then
		player.isJump = true;
	end
end

function IsLeftWallClimbCallback(fixture, x, y, xn, yn, fraction)
	if fixture:isSensor() then
		return -1;
	elseif player.isWallClimbEnabled then
		player.isLeftWallClimb = true;
		player.isDashAvailable = true;
		player.isJump = false;
		player.jumpAmount = player.jumpAmountMax;
		return 0;
	else 
		local x, y = player.body:getLinearVelocity();
		player.body:setX(player.body:getX() + 0.5);
		player.body:setLinearVelocity(0, y);
		return 0;
	end
end

function IsRightWallClimbCallback(fixture, x, y, xn, yn, fraction)
	if fixture:isSensor() then
		return -1;
	elseif player.isWallClimbEnabled then
		player.isRightWallClimb = true;
		player.isDashAvailable = true;
		player.isJump = false;
		player.jumpAmount = player.jumpAmountMax;
		return 0;
	else 
		local x, y = player.body:getLinearVelocity();
		player.body:setX(player.body:getX() - 0.5);
		player.body:setLinearVelocity(0, y);
		return 0;
	end
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
		if (self.isStand or (self.isWallClimbEnabled and (self.isLeftWallClimb or self.isRightWallClimb))) then
			self:actualJump();
		elseif (self.jumpAmount > 0) then
			self.jumpAmount = self.jumpAmount - 1;
			if not (self.isLeftWallClimb or self.isRightWallClimb) then
				player.particleEmitter:emit(30);
			end
			player:actualJump();
		end
	end
	
	self:checkWallClimbing(rayCastDepth);
	
	if self.isMoveLeft then
		self.body:applyForce(-self.speedX, 0);
		self.direction = self.directionEnum.left;
	end
	if self.isMoveRight then
		self.body:applyForce(self.speedX, 0);
		self.direction = self.directionEnum.right;
	end
	
	if not self.isDashEnabled then
		self.isDashAvailable = false;
	end
	
	if self.isDashEnabled then
		if self.isLeftDash and love.timer.getTime() < self.dashTimer + self.dashDuration and self.isDashAvailable then
			self.isDashAvailable = false;
			self.body:setLinearVelocity(-self.dashSpeed, 0);
			self.particleEmitter:emit(50);
			self.isLeftDash = true;
		elseif love.timer.getTime() > self.dashTimer + self.dashDuration and love.timer.getTime() < self.dashTimer + self.dashDuration * 1.5 then
			self.isLeftDash = false;
			self.body:setLinearVelocity(0, 0);
		elseif self.isLeftDash and love.timer.getTime() > self.dashTimer + self.dashDuration * 1.5 then
			self.isLeftDash = false;
		end
		
		if self.isRightDash and love.timer.getTime() < self.dashTimer + self.dashDuration then
			self.isDashAvailable = false;
			self.body:setLinearVelocity(self.dashSpeed, 0);
			self.particleEmitter:emit(50);
			self.isRightDash = true;
		elseif love.timer.getTime() > self.dashTimer + self.dashDuration and love.timer.getTime() < self.dashTimer + self.dashDuration * 1.5 then
			self.isRightDash = false;
			self.body:setLinearVelocity(0, 0);
		elseif self.isRightDash and love.timer.getTime() > self.dashTimer + self.dashDuration * 1.5 then
			self.isRightDash = false;
		end
	end
	
	if not (self.isLeftDash or self.isRightDash) then
		local x, y = self.body:getLinearVelocity();
		if math.abs(x) > self.speedXMax then
			self.body:setLinearVelocity(self.speedXMax * math.sign(x), y);
		end
	end
	
	if (self.isRightWallClimb) then
		self.body:applyForce(0, self.speedWallClimb * 10);
		self.direction = self.directionEnum.left;
	elseif (self.isLeftWallClimb) then
		self.body:applyForce(0, self.speedWallClimb * 10);
		self.direction = self.directionEnum.right;
	end
	
	self.particleEmitter:update(dt);
end

function player:checkWallClimbing(rayCastDepth)
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
end

function player:createBullet() 
	local block = {};
	block.width = layout.getX(10); 
	block.height = layout.getY(5); 
	block.x = self.body:getX(); 
	block.y = self.body:getY() - self.height * 0.2; 
	block.createdAt = love.timer.getTime();
	
	block.body = love.physics.newBody(world, block.x, block.y, "dynamic");
	block.body:setBullet(true);
	block.body:setFixedRotation(true);
	block.body:setGravityScale(0);
	block.shape = love.physics.newRectangleShape(block.width, block.height);
	block.fixture = love.physics.newFixture(block.body, block.shape);
	block.fixture:setUserData("bulletUser");

	local x, y = self.body:getLinearVelocity();
	if self.direction == self.directionEnum.right then 
		block.body:setX(block.body:getX() + (self.width + block.width) * 0.6);
		block.body:setLinearVelocity(self.bulletSpeed + x, 0);
	elseif self.direction == self.directionEnum.left then 
		block.body:setX(block.body:getX() - (self.width + block.width) * 0.6);
		block.body:setLinearVelocity(-self.bulletSpeed + x, 0);
	end
	
	table.insert(self.bulletList, block);
end

function player:keyboardShoot()
	if (self.isShootingEnabled and (love.timer.getTime() > self.lastShotTime + self.lastShotTimer)) then
		self.lastShotTime = love.timer.getTime();
		self:createBullet()
	end
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

    if level.activeMap and level.data.maps[level.activeMap] then
        if self.body:getY() > (sh * level.data.maps[level.activeMap].sizeY) + 50 then
            -- feature for speedrunners, will not be patched
            self:respawn();
        end
    end
 --self.body and v.body and not self.body:isDestroyed() and not v.body:isDestroyed() and
	for k, v in pairs(level.hazards) do
		if  self.body:isTouching(v.body) then
			level:goToSpawn(level.activeSpawn, true);
			break;
		end
	end
	
	for k, v in pairs(level.items) do
		if self.body:isTouching(v.body) then
			if (v.type == level.blockNameList.itemDash) then
				self.isDashEnabled = true;
			elseif (v.type == level.blockNameList.itemWallClimb) then
				self.isWallClimbEnabled = true;
			elseif (v.type == level.blockNameList.itemGun) then
				self.isShootingEnabled = true;
			elseif (v.type == level.blockNameList.itemDoubleJump) then
				self.jumpAmountMax = self.jumpAmountMax + 1; --must be later replaced with pre-defined value, now its just for testing purpose
			end
			v.body:destroy();
			level.items[k] = nil;
		end
	end

	for k, v in pairs(level.portals) do
		if self.body:isTouching(v.body) then
			if v.spawn then
				level:goToSpawn(v.spawn);
				break;
			end
		end
	end 
	for k, v in pairs(level.checkpoints) do
		if self.body:isTouching(v.body) then
			if v.spawn then
				level.activeSpawn = v.spawn;
				break;
			end
		end
	end
		
	for k, v in ipairs(self.bulletList) do
		if (v.body:isDestroyed()) then
			table.remove(self.bulletList, k);
		end
		
		if ((love.timer.getTime() > v.createdAt + self.bulletLifetime)) then
			v.body:destroy();
			table.remove(self.bulletList, k);
		end
	end
	
end

function player:draw()
	if (self.isLeftDash or self.isRightDash) then 
		love.graphics.setColor(1, 1, 1);
	else
		love.graphics.setColor(1, 0, 0);
	end
		
	local x, y = self.body:getPosition();
	
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))

	--animation:draw("player_walk", x - self.width * 0.5, y - self.height * 0.5, self.width, self.height);
	if (self.isLeftWallClimb) then
		love.graphics.rectangle("fill", self.body:getX(), self.body:getY()-self.height * 0.2, self.width, self.height * 0.3);
	elseif (self.isRightWallClimb) then
		love.graphics.rectangle("fill", self.body:getX(), self.body:getY()-self.height * 0.2, -self.width, self.height * 0.3);
	end
	
	love.graphics.setColor(1, 1, 0);
	if self.direction == self.directionEnum.left then 
		love.graphics.rectangle("fill", self.body:getX() - self.width * 0.5, self.body:getY()-self.height * 0.5, self.width * 0.1, self.height * 0.3);
	elseif self.direction == self.directionEnum.right then 
		love.graphics.rectangle("fill", self.body:getX() + self.width * 0.4, self.body:getY()-self.height * 0.5, self.width * 0.1, self.height * 0.3);
	end
	
	love.graphics.setColor(1, 1, 1);
	for k, v in ipairs(self.bulletList) do		
		if (not v.body:isDestroyed()) then
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()));
		end
	end

	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.particleEmitter, self.body:getX(), self.body:getY() + self.height * 0.5)
end