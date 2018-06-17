player = {};
function player:new()
	self.width  = layout.getX(50);
	self.height = layout.getY(100);
	self.startX = layout.getX(50);
	self.startY = layout.getY(50);
	self.speedX = layout.getY(10);
	self.speedXSprint = layout.getX(190) * love.physics.getMeter();
	self.speedXRegular = layout.getX(300) * love.physics.getMeter();
	self.speedXMax = layout.getX(10) * love.physics.getMeter();
	self.jumpSpeed = layout.getY(1000) * love.physics.getMeter();
	self.isSprint = false;
	self.isMoveLeft = false;
	self.isMoveRight = false;
	self.isJump = false;
	self.isStand = false;
	self.isLeftWallClimb = false;
	self.isRightWallClimb = false;
	self.speedWallClimb = layout.getY(5) * love.physics.getMeter();
	self.jumpAmount = 0;
	self.jumpAmountMax = 1;
	
	self.body = love.physics.newBody(world, self.startX, self.startY, "dynamic");
	self.body:setMass(100);
	self.body:setFixedRotation(true);
	self.shape = love.physics.newRectangleShape(self.width, self.height);
	self.fixture = love.physics.newFixture(self.body, self.shape);
end

function player:respawn()
	self.body:destroy();
	self:new();
end

function actualJump(fixture, x, y, xn, yn, fraction)
	if (player.isJump) then
		if player.isLeftWallClimb then
			player.body:setLinearVelocity(0, 0);
			player.body:applyForce(player.jumpSpeed * love.physics.getMeter(), -player.jumpSpeed * love.physics.getMeter())
			player.isJump = false;
		elseif player.isRightWallClimb then
			player.body:setLinearVelocity(0, 0);
			player.body:applyForce(-player.jumpSpeed * love.physics.getMeter(), -player.jumpSpeed * love.physics.getMeter())
			player.isJump = false;
		else
			local x, y = player.body:getLinearVelocity();
			player.body:setLinearVelocity(x, 0);
			player.body:applyForce(0, -player.jumpSpeed * love.physics.getMeter())
			player.isJump = false;
		end
		player.isStand = false;
	end
	return 1
end


function IsStandCallback(fixture, x, y, xn, yn, fraction)
	player.jumpAmount = player.jumpAmountMax;
	player.isStand = true;
	return 1;
end

function jumpKeyPressed( key, scancode, isrepeat) 
	if key == "space" then
		player.isJump = true;
	end
end

function IsLeftWallClimbCallback(fixture, x, y, xn, yn, fraction)
	player.isLeftWallClimb = true;
	player.jumpAmount = player.jumpAmountMax;
	return 1;
end

function IsRightWallClimbCallback(fixture, x, y, xn, yn, fraction)
	player.isRightWallClimb = true;
	player.jumpAmount = player.jumpAmountMax;
	return 1;
end

function player:move()
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
	world:rayCast(self.body:getX(), 
		self.body:getY() + self.height * 0.5, 
		self.body:getX(), 
		self.body:getY() + self.height * 0.5 + rayCastDepth, 
		IsStandCallback
	);
	world:rayCast(self.body:getX() + self.width * 0.5, 
		self.body:getY() + self.height * 0.5, 
		self.body:getX() + self.width * 0.5, 
		self.body:getY() + self.height * 0.5 + rayCastDepth, 
		IsStandCallback
	);
	
	if self.isJump then
		if (self.isStand) then
			world:rayCast(self.body:getX() - self.width * 0.5, 
				self.body:getY() + self.height * 0.5, 
				self.body:getX() - self.width * 0.5, 
				self.body:getY() + self.height * 0.5 + rayCastDepth, 
				actualJump
			);
			world:rayCast(self.body:getX(), 
				self.body:getY() + self.height * 0.5, 
				self.body:getX(), 
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
			self.body:getY(), 
			self.body:getX() - self.width * 0.5 - rayCastDepth, 
			self.body:getY(), 
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
			self.body:getY(), 
			self.body:getX() + self.width * 0.5 + rayCastDepth, 
			self.body:getY(), 
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
	
	local x, y = self.body:getLinearVelocity();
	if (math.abs(x) > self.speedXMax) then
		self.body:setLinearVelocity(self.speedXMax * math.sign(x), y);
	end;
	
	if (self.isRightWallClimb or self.isLeftWallClimb) then
		self.body:applyForce(0, self.speedWallClimb * 10);
	end
end