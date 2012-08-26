--[[
	State base class. All other states should inherit from this.
]]


Player = class();

function Player:constructor()
	self.name = "playername"
	self.HP = 1000
	self.MaxHP = 1000
	self.Heal = 60
	self.HealCD = 25
	self.X = 0
	self.Z = 0
	self.Y = 0
	self.Dir1 = 0
	self.Dir2 = 0
	self.TargetMob = 0
	self.TargetAll = 0
	self.Loot = false
	self.Interaction = false
	self.InCombat = false

	self.turnDir = nil; -- Turn left/right
	self.fbMovement = nil; -- Move forward/backward
end

function Player:update()
	local proc = getProc()
	self.HP = memoryReadFloatPtr(proc, addresses.playerbasehp, addresses.playerHPoffset) or self.HP;
	self.MaxHP = memoryReadFloatPtr(proc, addresses.playerbasehp, addresses.playerMaxHPoffset) or self.MaxHP;
	self.X = memoryReadFloat(proc, addresses.playercoords + addresses.playerX) or self.X;
	self.Z = memoryReadFloat(proc, addresses.playercoords + addresses.playerZ) or self.Z;
	self.Y = memoryReadFloat(proc, addresses.playercoords + addresses.playerY) or self.Y;
	self.Dir1 = memoryReadFloat(proc, addresses.playercoords + addresses.playerDir1) or self.Dir1;
	self.Dir2 = memoryReadFloat(proc, addresses.playercoords + addresses.playerDir2) or self.Dir2;
	self.TargetMob = memoryReadInt(proc, addresses.TargetMob) or self.TargetMob;
	self.TargetAll = memoryReadInt(proc, addresses.TargetAll) or self.TargetAll;
	self.Loot = (memoryReadInt(proc, addresses.lootwindow) ~= 0)
	self.Interaction = (memoryReadInt(proc, addresses.Finteraction) ~= 0)
	self.InCombat = (memoryReadInt(proc, addresses.playerInCombat) ~= 0)



	self.Angle = math.atan2(self.Dir2, self.Dir1) + math.pi;
end


--		self.fbMovement
function Player:moveForward()
	if( self.fbMovement == "forward" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.fbMovement == "backward" ) then
		keyboardRelease(key.VK_S); -- Stop turning right
	end

	self.fbMovement = "forward";

	keyboardHold(key.VK_W);
end

function Player:moveBackward()
	if( self.fbMovement == "backward" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.fbMovement == "forward" ) then
		keyboardRelease(key.VK_W); -- Stop turning right
	end

	self.fbMovement = "backward";

	keyboardHold(key.VK_S);
end

function Player:stopMoving()
	if( not self.fbMovement ) then
		return;
	end

	if( self.fbMovement == "forward" ) then
		keyboardRelease(key.VK_W);
	else
		keyboardRelease(key.VK_S);
	end

	self.fbMovement = nil;
end

function Player:turnLeft()
	if( self.turnDir == "left" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.turnDir == "right" ) then
		keyboardRelease(key.VK_D); -- Stop turning right
	end

	self.turnDir = "left";

	keyboardHold(key.VK_A);
end

function Player:turnRight()
	if( self.turnDir == "right" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.turnDir == "left" ) then
		keyboardRelease(key.VK_A); -- Stop turning left
	end

	self.turnDir = "right";

	keyboardHold(key.VK_D);
end

function Player:stopTurning()
	if( not self.turnDir ) then
		return;
	end

	if( self.turnDir == "left" ) then
		keyboardRelease(key.VK_A);
	else
		keyboardRelease(key.VK_D);
	end

	self.turnDir = nil;
end

function Player:moveTo(x, y, z)
	x = x or 0;
	y = y or 0;
	z = z or 0;
end