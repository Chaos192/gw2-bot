--[[
	State base class. All other states should inherit from this.
]]

Player = class();

function Player:constructor()
	self.Name = "playername"
	self.Karma = 0
	self.Gold = 0
	self.monthlyXP = 0
	self.HP = 1000
	self.MaxHP = 1000
	self.Heal = profile['heal'] or 60
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
	self.Ftext = ""

	self.turnDir = nil; -- Turn left/right
	self.fbMovement = nil; -- Move forward/backward
	self.skill1used = 0
	self.skill2used = 0
	self.skill3used = 0
	self.skill4used = 0
	self.skill5used = 0
	self.skill6used = 0
	self.skill7used = 0
	self.skill8used = 0
	self.skill9used = 0	
	self.skill0used = 0
end

--		self.fbMovement
function Player:moveForward()
	if( self.fbMovement == "forward" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.fbMovement == "backward" ) then
		keyboardRelease(keySettings['backward']); -- Stop turning right
	end

	self.fbMovement = "forward";

	keyboardHold(keySettings['forward']);
end

function Player:moveBackward()
	if( self.fbMovement == "backward" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.fbMovement == "forward" ) then
		keyboardRelease(keySettings['forward']); -- Stop turning right
	end

	self.fbMovement = "backward";

	keyboardHold(keySettings['backward']);
end

function Player:stopMoving()
	if( not self.fbMovement ) then
		return;
	end

	if( self.fbMovement == "forward" ) then
		keyboardRelease(keySettings['forward']);
	else
		keyboardRelease(keySettings['backward']);
	end

	self.fbMovement = nil;
end

function Player:turnLeft()
	if( self.turnDir == "left" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.turnDir == "right" ) then
		keyboardRelease(keySettings['turnright']); -- Stop turning right
	end

	self.turnDir = "left";

	keyboardHold(keySettings['turnleft']);
end

function Player:turnRight()
	if( self.turnDir == "right" ) then
		return; -- If we're already doing it, ignore this call.
	end

	if( self.turnDir == "left" ) then
		keyboardRelease(keySettings['turnleft']); -- Stop turning left
	end

	self.turnDir = "right";

	keyboardHold(keySettings['turnright']);
end

function Player:stopTurning()
	if( not self.turnDir ) then
		return;
	end

	if( self.turnDir == "left" ) then
		keyboardRelease(keySettings['turnleft']);
	else
		keyboardRelease(keySettings['turnright']);
	end

	self.turnDir = nil;
end

function Player:facedirection(x, z,_angle)
	x = x or 0;
	z = z or 0;
	_angle = _angle or 0.3
	-- Check our angle to the waypoint.
	local angle = math.atan2(z - self.Z, x - self.X) + math.pi;
	local anglediff = self.Angle - angle;

	if( math.abs(anglediff) > _angle ) then
		if( self.fbMovement ) then -- Stop running forward.
			self:stopMoving();
		end

		-- Attempt to face it
		if( anglediff < 0 or anglediff > math.pi ) then
			-- Rotate left
			self:turnLeft();
		else
			-- Rotate right
			self:turnRight();
		end
	else
		self:stopTurning();
		return true
	end
end

function Player:moveTo_step(x, z,_dist)
	x = x or 0;
	z = z or 0;

	-- Check our angle to the waypoint.
	local angle = math.atan2(z - self.Z, x - self.X) + math.pi;
	local anglediff = self.Angle - angle;

	if player:facedirection(x, z) then
		if distance(player.X, player.Z, x, z) > _dist then
			self:moveForward()
		else
			self:stopMoving()
			return true
		end
	end

end

function Player:useSkills(_heal)
	if _heal then
		if profile['skill6use'] == true and os.difftime(os.time(),self.skill6used) > profile['skill6cd'] + SETTINGS['lagallowance'] then
			keyboardPress(key.VK_6)
			if profile['skill6ground'] == true then
				keyboardPress(key.VK_6)
			end
			cprintf(cli.green,"heal key 6\n")
			yrest(profile['skill6casttime']*1000)
			self.skill6used = os.time()
		end
		return
	end
	if profile['skill2use'] == true and os.difftime(os.time(),self.skill2used) > profile['skill2cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_2)
		if profile['skill2ground'] == true then
			keyboardPress(key.VK_2)
		end
		cprintf(cli.red,"attack 2\n")
		yrest(profile['skill2casttime']*1000)
		self.skill2used = os.time()
		return
	end
	if profile['skill3use'] == true and os.difftime(os.time(),self.skill3used) > profile['skill3cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_3)
		if profile['skill3ground'] == true then
			keyboardPress(key.VK_3)
		end
		cprintf(cli.red,"attack 3\n")
		yrest(profile['skill3casttime']*1000)
		self.skill3used = os.time()
		return
	end
	if profile['skill4use'] == true and os.difftime(os.time(),self.skill4used) > profile['skill4cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_4)	
		if profile['skill4ground'] == true then
			keyboardPress(key.VK_4)
		end
		cprintf(cli.red,"attack 4\n")
		yrest(profile['skill4casttime']*1000)
		self.skill4used = os.time()
		return
	end
	if profile['skill5use'] == true and os.difftime(os.time(),self.skill5used) > profile['skill5cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_5)
		if profile['skill5ground'] == true then
			keyboardPress(key.VK_5)
		end
		cprintf(cli.red,"attack 5\n")
		yrest(profile['skill5casttime']*1000)
		self.skill5used = os.time()
		return		
	end
	if profile['skill7use'] == true and os.difftime(os.time(),self.skill7used) > profile['skill7cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_7)
		if profile['skill7ground'] == true then
			keyboardPress(key.VK_7)
		end
		cprintf(cli.red,"attack 7\n")	
		yrest(profile['skill7casttime']*1000)
		self.skill7used = os.time()
		return		
	end
	if profile['skill8use'] == true and os.difftime(os.time(),self.skill8used) > profile['skill8cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_8)
		if profile['skill8ground'] == true then
			keyboardPress(key.VK_8)
		end
		cprintf(cli.red,"attack 8\n")
		yrest(profile['skill8casttime']*1000)
		self.skill8used = os.time()
		return
	end
	if profile['skill9use'] == true and os.difftime(os.time(),self.skill9used) > profile['skill9cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_9)
		if profile['skill9ground'] == true then
			keyboardPress(key.VK_9)
		end
		cprintf(cli.red,"attack 9\n")
		yrest(profile['skill9casttime']*1000)
		self.skill9used = os.time()
		return
	end
	if profile['skill0use'] == true and os.difftime(os.time(),self.skill0used) > profile['skill0cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_0)
		if profile['skill0ground'] == true then
			keyboardPress(key.VK_0)
		end
		cprintf(cli.red,"attack 0\n")
		yrest(profile['skill0casttime']*1000)
		self.skill0used = os.time()
		return		
	end
	if os.difftime(os.time(),self.skill1used) > profile['skill1cd'] then
		keyboardPress(key.VK_1)
		self.skill1used = os.time()	
	end	
end