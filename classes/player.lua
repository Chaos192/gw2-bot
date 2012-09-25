--[[
	State base class. All other states should inherit from this.
]]

Player = class();

function Player:constructor()
	self.Name = "playername"
	self.Karma = 0
	self.Gold = 0
	--self.monthlyXP = 0
	self.HP = 1000
	self.MaxHP = 1000
	self.XP = 1
	self.XPnextlvl = 1
	self.actlvl = 1
	self.adjlvl = 1
	self.Heal = profile['heal'] or 60
	self.HealCD = 25
	self.X = 0
	self.Z = 0
	self.Y = 0
	self.Dir1 = 0
	self.Dir2 = 0
	self.Angle = 0
	self.TargetMob = 0
	self.TargetAll = 0
	self.Loot = false
	self.Interaction = false
	self.InteractionId = 0;
	self.InCombat = false
	self.Ftext = ""
	self.skill = {}
	self.skill[1] = 0
	self.skill[2] = 0
	self.skill[3] = 0
	self.skill[4] = 0
	self.skill[5] = 0
	self.skill[6] = 0
	self.skill[7] = 0
	self.skill[8] = 0
	self.skill[9] = 0
	self.skill[0] = 0
	
	self.turnDir = nil; -- Turn left/right
	self.fbMovement = nil; -- Move forward/backward
	self.skill1used = 0
	self.skillF1used = 0
	self.skillF2used = 0
	self.skillF3used = 0
	self.skillF4used = 0
	self.movementLastUpdate = getTime();
	self.curtime = 0
	self.LastX = 0
	self.LastZ = 0
end

function Player:stopMoving()
	local proc = getProc();
	-- Ensure we're not moving
	memoryWriteInt(proc, addresses.moveForward, 0);
	memoryWriteInt(proc, addresses.moveBackward, 0);
end

function Player:stopTurning()
	local proc = getProc();
	-- Ensure we're not turning
	memoryWriteInt(proc, addresses.turnLeft, 0);
	memoryWriteInt(proc, addresses.turnRight, 0);

end

function Player:move(direction, dist)
	local stop = false
	local proc = getProc()
	dist = dist or 100
	
	local deltatime
	if direction == "left" or direction == "right" then
		deltatime = 100
	else
		deltatime = 200
	end	
	
	if deltaTime(self.curtime, self.movementLastUpdate) > deltatime then
		memoryWriteInt(proc, addresses.turnRight, 0);	
		memoryWriteInt(proc, addresses.turnLeft, 0);
		if 200 > dist then 
			memoryWriteInt(proc, addresses.moveForward, 0);
			memoryWriteInt(proc, addresses.moveBackward, 0);
		end
		if direction == "left" then
			-- Ensure we're turning left.
			memoryWriteInt(proc, addresses.turnLeft, 1);
		elseif( direction == "right" ) then
			-- Ensure we're turning right.
			memoryWriteInt(proc, addresses.turnRight, 1);
		end
		if( direction == "forward" ) then
			if 20 > distance(self.LastX,self.LastZ,self.X,self.Z) then
				print("not moving")
				-- deal with not moving here.
			end
			self.LastX = self.X
			self.LastZ = self.Z
			-- Ensure we're moving foward
			memoryWriteInt(proc, addresses.moveForward, 1);
		elseif( direction == "backward" ) then
			-- Ensure we're moving backward
			memoryWriteInt(proc, addresses.moveBackward, 1);
		end
		self.movementLastUpdate = self.curtime;
	end
end

-- self.Angle: 0 (2*Pi) = West, 1,57 (Pi/2) = South, 3,14(Pi) = East, 4,71 (Pi+Pi/2) = North
function Player:facedirection(x, z, _angle, dist)
	self.curtime = getTime()
	coordsupdate()
	x = x or 0;
	z = z or 0;
	_angle = _angle or 0.4
	-- Check our angle to the waypoint.
	local angle = math.atan2(z - self.Z, x - self.X) + math.pi;
	local angleDif = angleDifference(angle, self.Angle);
	
	if( angleDif > _angle ) then
		-- Attempt to face it
		if angleDif > angleDifference(angle, self.Angle+ 0.01) then
			-- Rotate left
			logger:log('debug-moving','at Player:facedirection: move left %.2f > angleDifference: %.2f', angleDif, angleDifference(angle, self.Angle+ 0.01));
			self:move("left", dist)
		else
			-- Rotate right
			logger:log('debug-moving','at Player:facedirection: move right %.2f <= angleDifference: %.2f', angleDif, angleDifference(angle, self.Angle+ 0.01));
			self:move("right",dist)
		end
	else
		logger:log('debug-moving','at Player:facedirection: facing ok, angleDif: %.2f < _angle: %.2f', angleDif, _angle);
		self:stopTurning()		-- no turning after looking in right direction 
		return true
	end
end

function Player:moveTo_step(x, z, _dist)
	_dist = _dist or 100;
	coordsupdate()
	x = x or 0;
	z = z or 0;
	local angle
	local dist = distance(self.X, self.Z, x, z)
	
	if 400 > dist then angle = 0.5 else angle = 0.2 end
	logger:log('debug-moving',"at Player:moveTo_step: Distance %d from WP (%d,%d)", dist, x, z);
	if self:facedirection(x, z, angle, dist) then
		if dist > _dist then
			self:move("forward")
		else
			self:stopMoving()		-- no moving after being there 
			return true
		end
	else
		logger:log('debug-moving','at Player:moveTo_step: not moving because self:facedirection() = false');
	end
end

-- look for target by pressing Next Target Button
-- _dist = distance to look for target within (default value = profile setting)
--	['maxdistance'] = 2000, -- max distance to decide to attack mob
--	['fightdistance'] = 1100, -- distance when start to use skills, melee should be low (50)

function Player:getNextTarget(_dist)

	if not _dist then
		_dist = profile['maxdistance']
	end
	
	keyboardPress(keySettings['nexttarget'])
	
	targetupdate()
	coordsupdate()
	if self.TargetMob == 0 then
		return false
	end
	
	local hf_dist = distance( self.X, self.Z, target.TargetX, target.TargetZ)

	if  hf_dist < _dist then	-- target within distances?
		logger:log('info',"choose new target %s in distance %d\n", self.TargetMob, hf_dist);
		return true
	else
		logger:log('debug', "Target %s is too far. distance=%d > maxdistance=%d\n", self.TargetMob, hf_dist, _dist);
		keyboardPress(key.VK_ESCAPE)	-- TODO / use memwrite function to clear target
		targetupdate()
		return false
	end


end

function Player:useSkills(_heal)
	local proc = getProc()
	local dist = distance(self.X, self.Z, target.TargetX, target.TargetZ)	
	if _heal then
		if profile['skill6use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x9C, 0x40, 0x4C, 0xA}) == 0x300000) then
			keyboardPress(key.VK_6)
			if profile['skill6ground'] == true then
				keyboardPress(key.VK_6)
			end
			cprintf(cli.green,"heal key 6 with ID "..self.skill[6].."\n")
			yrest(profile['skill6casttime']*1000)
		end
		return
	end

	if( dist > profile['fightdistance'] ) then
		return; -- Too far; don't use skills
	end
	if os.difftime(os.time(),self.skill1used) > 1 then
		keyboardPress(key.VK_1)
		cprintf(cli.green,"using skill 1 with ID "..self.skill[1].."\n")
		self.skill1used = os.time()	
	end
	if profile['skill2use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x6C, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(key.VK_2)
		if profile['skill2ground'] == true then
			keyboardPress(key.VK_2)
		end
		cprintf(cli.red,"using skill 2 with ID "..self.skill[2].."\n")
		yrest(profile['skill2casttime']*1000)
		return
	end
	if profile['skill3use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x78, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(key.VK_3)
		if profile['skill3ground'] == true then
			keyboardPress(key.VK_3)
		end
		cprintf(cli.red,"using skill 3 with ID "..self.skill[3].."\n")
		yrest(profile['skill3casttime']*1000)
		return
	end
	if profile['skill4use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x84, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(key.VK_4)	
		if profile['skill4ground'] == true then
			keyboardPress(key.VK_4)
		end
		cprintf(cli.red,"using skill 4 with ID "..self.skill[4].."\n")
		yrest(profile['skill4casttime']*1000)
		return
	end	
	if profile['skill5use'] == true and (memoryReadRepeat("intptr", proc, 0x153E7A4 ,{0x54, 0x160, 0x24,0x14,0xA}) == 0x300000) then
		keyboardPress(key.VK_5)
		if profile['skill5ground'] == true then
			keyboardPress(key.VK_5)
		end
		cprintf(cli.red,"using skill 5 with ID "..self.skill[5].."\n")
		yrest(profile['skill5casttime']*1000)
		return
	end
	if profile['skill7use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xA8, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(key.VK_7)
		if profile['skill7ground'] == true then
			keyboardPress(key.VK_7)
		end
		cprintf(cli.red,"using skill 7 with ID "..self.skill[7].."\n")	
		yrest(profile['skill7casttime']*1000)
		return
	end
	if profile['skill8use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xB4, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(key.VK_8)
		if profile['skill8ground'] == true then
			keyboardPress(key.VK_8)
		end
		cprintf(cli.red,"using skill 8 with ID "..self.skill[8].."\n")
		yrest(profile['skill8casttime']*1000)
		return
	end
	if profile['skill9use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xC0, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(key.VK_9)
		if profile['skill9ground'] == true then
			keyboardPress(key.VK_9)
		end
		cprintf(cli.red,"using skill 9 with ID "..self.skill[9].."\n")
		yrest(profile['skill9casttime']*1000)
		return
	end
	if profile['skill0use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xC0, 0x174, 0x54, 0xA}) == 0x300000) then
		keyboardPress(key.VK_0)
		if profile['skill0ground'] == true then
			keyboardPress(key.VK_0)
		end
		cprintf(cli.red,"using skill 0 with ID "..self.skill[0].."\n")
		yrest(profile['skill0casttime']*1000)
		return
	end	
	
	--=== Engineer ===--
	if profile['skillF1use'] == true and os.difftime(os.time(),self.skillF1used) > profile['skillF1cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_F1)
		if profile['skillF1ground'] == true then
			keyboardPress(key.VK_F1)
		end
		cprintf(cli.red,"attack F1\n")
		yrest(profile['skillF1casttime']*1000)
		self.skillF1used = os.time()
		return		
	end
	if profile['skillF2use'] == true and os.difftime(os.time(),self.skillF2used) > profile['skillF2cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_F2)
		if profile['skillF2ground'] == true then
			keyboardPress(key.VK_F2)
		end
		cprintf(cli.red,"attack F2\n")
		yrest(profile['skillF2casttime']*1000)
		self.skillF2used = os.time()
		return		
	end
	if profile['skillF3use'] == true and os.difftime(os.time(),self.skillF3used) > profile['skillF3cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_F3)
		if profile['skillF3ground'] == true then
			keyboardPress(key.VK_F3)
		end
		cprintf(cli.red,"attack F3\n")
		yrest(profile['skillF3casttime']*1000)
		self.skillF3used = os.time()
		return		
	end
	if profile['skillF4use'] == true and os.difftime(os.time(),self.skillF4used) > profile['skillF4cd'] + SETTINGS['lagallowance'] then
		keyboardPress(key.VK_F4)
		if profile['skillF4ground'] == true then
			keyboardPress(key.VK_F4)
		end
		cprintf(cli.red,"attack F4\n")
		yrest(profile['skillF4casttime']*1000)
		self.skillF4used = os.time()
		return		
	end
end