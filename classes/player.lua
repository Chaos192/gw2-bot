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
	self.ServX = 0
	self.ServZ = 0
	self.ServY = 0
	self.Dir1 = 0
	self.Dir2 = 0
	self.Angle = 0
	self.TargetMob = 0
	self.TargetAll = 0
	self.Interaction = false
	self.InteractionId = 0;
	self.InCombat = false
	self.Ftext = ""
	self.Fid = 0
	self.Alive = true
	self.Downed = false
	self.Dead = false

	self.blockedTargets = {}			-- remember targets to ignore
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
	self.skill["F1"] = 0
	self.skill["F2"] = 0
	self.skill["F3"] = 0
	self.skill["F4"] = 0
	self.skill["U1"] = 0
	self.skill["U2"] = 0
	self.skill["U3"] = 0	
	self.turnDir = nil; -- Turn left/right
	self.fbMovement = nil; -- Move forward/backward
	self.skill1used = 0
	self.skillF1used = 0
	self.skillF2used = 0
	self.skillF3used = 0
	self.skillF4used = 0
	self.lastSkillTimer = 0					-- Casttime of used Spell
	self.lastSkilluseTime = getTime()			-- last time we used a skill
	self.movementLastUpdate = getTime();
	self.curtime = 0
	self.LastX = 0
	self.LastZ = 0
	self.notMovingTime = nil	-- time we last moved successfully to detect not moving situations	
end

function Player:stopMoving()
local proc = getProc()
	-- Ensure we're not moving
	memoryWriteInt(proc, addresses.moveForward, 0);
	memoryWriteInt(proc, addresses.moveBackward, 0);
end

function Player:stopTurning()
local proc = getProc()
	-- Ensure we're not turning
	memoryWriteInt(proc, addresses.turnLeft, 0);
	memoryWriteInt(proc, addresses.turnRight, 0);

end

function Player:move(direction, dist)
local proc = getProc()
	local stop = false
	dist = dist or 10
	
	local deltatime
	if direction == "left" or direction == "right" then
		deltatime = 100
	else
		deltatime = 200
	end	
	
	if deltaTime(self.curtime, self.movementLastUpdate) > deltatime then
		memoryWriteInt(proc, addresses.turnRight, 0);	
		memoryWriteInt(proc, addresses.turnLeft, 0);
		if 20 > dist then 
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
			if 1 > distance(self.LastX,self.LastZ,self.X,self.Z) then
				if not self.notMovingTime then
					self.notMovingTime = getTime()
				end
				if deltaTime(getTime(), self.notMovingTime ) > 5000 then 	-- we stick for more then 5 sec, stop the bot
					--error('we dont move since more then 5 seconds. We stop the bot',0)
				elseif deltaTime(getTime(), self.notMovingTime ) > 200 then -- TODO: unstick state
					logger:log('info',"not moving");
					-- deal with not moving here.
					keyboardPress(key.VK_SPACE)
				end
			else
				self.notMovingTime = nil	-- we moved successfully
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
	_angle = _angle or 0.1
	-- Check our angle to the waypoint.
	local angle = math.atan2(z - self.Z, x - self.X) + math.pi;
	local angleDif = angleDifference(angle, self.Angle);

	if( angleDif > _angle ) then
		-- Attempt to face it
		if angleDif > angleDifference(angle, self.Angle+ 0.01) then
			-- Rotate left
			logger:log('debug-moving','at Player:facedirection: move left angleDif: %.2f > _angle: %.2f', angleDif, _angle);
			self:move("left", dist)
		else
			-- Rotate right
			logger:log('debug-moving','at Player:facedirection: move right angleDif %.2f > _angle: %.2f', angleDif, _angle);
			self:move("right",dist)
		end
	else
		logger:log('debug-moving','at Player:facedirection: facing ok, angleDif: %.2f < _angle: %.2f', angleDif, _angle);
		self:stopTurning()		-- no turning after looking in right direction 
		return true
	end
end

function Player:moveTo_step(x, z, _dist)
	local proc = getProc()
	_dist = _dist or 5
	coordsupdate()
	x = x or 0;
	z = z or 0;
	local angle
	local dist = distance(self.X, self.Z, x, z)
	
	if 15 > dist then 
		angle = 0.5 
	else 
		angle = 0.2 
	end

	logger:log('debug-moving',"at Player:moveTo_step: Distance %d from WP (%d,%d)", dist, x, z);
	if self:facedirection(x, z, angle, dist) then
		if dist > 10 and memoryReadInt(proc, addresses.moveForward) == 1 then 
			local tar = targetnearestmob()
			if tar then 
				self:stopMoving()
				stateman:pushState(FirstattackState()) 
				return
			end
		end
		if dist > _dist then
			self:move("forward")
		else
			logger:log('debug',"at Player:moveTo_step: stopMoving() we are close at (%d,%d) dist %d < %d", x, z, dist, _dist);
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

--debug_value(self.TargetMob,"self.TargetMob")
--debug_value(self.blockedTargets[self.TargetMob],"self.blockedTargets[self.TargetMob] in getnext")
--if self.blockedTargets[self.TargetMob] then
--debug_value(self.blockedTargets[self.TargetMob].count,"self.blockedTargets[self.TargetMob].count")
--debug_value(os.difftime(os.time(),self.blockedTargets[self.TargetMob].time ),"os.difftime(os.time(),self.blockedTargets[self.TargetMob].time )")
--end

	-- check blocked targets
	if self.blockedTargets[self.TargetMob]   and		-- short term block
	   self.blockedTargets[self.TargetMob].count < 4	and
	   os.difftime(os.time(),self.blockedTargets[self.TargetMob].time ) < 4	then 	-- only target again after x seconds
		logger:log('debug',"target %d is blocked for 3 seconds\n", self.TargetMob);
		keyboardPress(key.VK_ESCAPE)	-- TODO / use memwrite function to clear target
		return false
	end

	if self.blockedTargets[self.TargetMob]   and		-- long term block
	   self.blockedTargets[self.TargetMob].count == 4	and
	   os.difftime(os.time(),self.blockedTargets[self.TargetMob].time ) < 300	then 	-- only target again after x seconds
		logger:log('debug',"target %d is blocked for 5 minutes\n", self.TargetMob);
		keyboardPress(key.VK_ESCAPE)	-- TODO / use memwrite function to clear target
		return false
	end

	if self.blockedTargets[self.TargetMob]   and		-- final block
	   self.blockedTargets[self.TargetMob].count > 4	then
		logger:log('debug',"target %d is finaly blocked\n", self.TargetMob);
		keyboardPress(key.VK_ESCAPE)	-- TODO / use memwrite function to clear target
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
-- FIX until memwrite works for all classes
	if ( SETTINGS['useKeypress'] ) then
		self:useSkillsKeypress(_heal)
		return
	end

--	emergency heal?
	if (_heal) and
	   profile['healEmergency'] > player.HP/player.MaxHP*100 then
		self.lastSkillTimer = 0
	end

	if _heal then
		if profile['skill6use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x9C, 0x40, 0x4C, 0xA}) == 0x300000) then
			logger:log('info',"use heal skills at %d/%d health (healing startes at %d percent)\n", self.HP, self.MaxHP, self.Heal);
			keyboardPress(keySettings['skillheal'])
			if profile['skill6ground'] == true then
				keyboardPress(keySettings['skillheal'])
			end
			cprintf(cli.green,"heal key %s with ID %s\n", getKeyName(keySettings['skillheal']), self.skill[6])
			yrest(profile['skill6casttime']*1000)
		end
		return
	end

	local dist = distance(self.X, self.Z, target.TargetX, target.TargetZ)	
	if( dist > profile['fightdistance'] ) then
		return; -- Too far; don't use skills
	end
	
	if os.difftime(os.time(),self.skill1used) > 1 then
		keyboardPress(keySettings['skillweapon1'])
		cprintf(cli.green,"using skill key %s with ID %s\n", getKeyName(keySettings['skillweapon1']), self.skill[1])
		self.skill1used = os.time()	
	end
	if profile['skill2use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x84, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(keySettings['skillweapon2'])
		if profile['skill2ground'] == true then
			keyboardPress(keySettings['skillweapon2'])
		end
		cprintf(cli.red,"using skill key %s with ID %s\n", getKeyName(keySettings['skillweapon2']), self.skill[2])
		yrest(profile['skill2casttime']*1000)
		return
	end
	if profile['skill3use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x84, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(keySettings['skillweapon3'])
		if profile['skill3ground'] == true then
			keyboardPress(keySettings['skillweapon3'])
		end
		cprintf(cli.red,"using skill key %s with ID %s\n", getKeyName(keySettings['skillweapon3']), self.skill[3])
		yrest(profile['skill3casttime']*1000)
		return
	end
	if profile['skill4use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0x9C, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(keySettings['skillweapon4'])	
		if profile['skill4ground'] == true then
			keyboardPress(keySettings['skillweapon4'])
		end
		cprintf(cli.red,"using skill key %s with ID %s\n", getKeyName(keySettings['skillweapon4']), self.skill[4])
		yrest(profile['skill4casttime']*1000)
		return
	end	
	if profile['skill5use'] == true and (memoryReadRepeat("intptr", proc, 0x155D8AC ,{0x54, 0x160, 0x24,0x14,0xA}) == 0x300000) then
		keyboardPress(keySettings['skillweapon5'])
		if profile['skill5ground'] == true then
			keyboardPress(keySettings['skillweapon5'])
		end
		cprintf(cli.red,"using skill key %s with ID %s\n", getKeyName(keySettings['skillweapon5']), self.skill[5])
		yrest(profile['skill5casttime']*1000)
		return
	end
	if profile['skill7use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xC0, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(keySettings['skillhelp1'])
		if profile['skill7ground'] == true then
			keyboardPress(keySettings['skillhelp1'])
		end
		cprintf(cli.red,"using skill key %s with ID %s\n", getKeyName(keySettings['skillhelp1']), self.skill[7])
		yrest(profile['skill7casttime']*1000)
		return
	end
	if profile['skill8use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xCC, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(keySettings['skillhelp2'])
		if profile['skill8ground'] == true then
			keyboardPress(keySettings['skillhelp2'])
		end
		cprintf(cli.red,"using skill key %s with ID %s\n", getKeyName(keySettings['skillhelp2']), self.skill[8])
		yrest(profile['skill8casttime']*1000)
		return
	end
	if profile['skill9use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xD8, 0x40, 0x4C, 0xA}) == 0x300000) then
		keyboardPress(keySettings['skillhelp3'])
		if profile['skill9ground'] == true then
			keyboardPress(keySettings['skillhelp3'])
		end
		cprintf(cli.red,"using skill key %s with ID %s\n", getKeyName(keySettings['skillhelp3']), self.skill[9])
		yrest(profile['skill9casttime']*1000)
		return
	end
	if profile['skill0use'] == true and (memoryReadRepeat("intptr", proc, addresses.skillCDaddress,{0xB0, 0xCC, 0x174, 0x54, 0xA}) == 0x300000) then
		keyboardPress(keySettings['skillelite'])
		if profile['skill0ground'] == true then
			keyboardPress(keySettings['skillelite'])
		end
		cprintf(cli.red,"using eliteskill key %s with ID %s\n", getKeyName(keySettings['skillelite']), self.skill[0])
		yrest(profile['skill0casttime']*1000)
		return
	end	
	
	--=== Engineer ===--
	if profile['skillF1use'] == true and os.difftime(os.time(),self.skillF1used) > profile['skillF1cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass1'])
		if profile['skillF1ground'] == true then
			keyboardPress(keySettings['skillclass1'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass1']))
		self.lastSkilluseTime = getTime()							-- last time we used a skill/ to calculate casting timer
		self.lastSkillTimer = profile['skillF1casttime']*1000		-- Casttime of used Spell			
--		yrest(profile['skillF1casttime']*1000)
		self.skillF1used = os.time()
		return		
	end
	if profile['skillF2use'] == true and os.difftime(os.time(),self.skillF2used) > profile['skillF2cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass2'])
		if profile['skillF2ground'] == true then
			keyboardPress(keySettings['skillclass2'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass2']))
		self.lastSkilluseTime = getTime()							-- last time we used a skill/ to calculate casting timer
		self.lastSkillTimer = profile['skillF2casttime']*1000		-- Casttime of used Spell			
--		yrest(profile['skillF2casttime']*1000)
		self.skillF2used = os.time()
		return		
	end
	if profile['skillF3use'] == true and os.difftime(os.time(),self.skillF3used) > profile['skillF3cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass3'])
		if profile['skillF3ground'] == true then
			keyboardPress(keySettings['skillclass3'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass3']))
		self.lastSkilluseTime = getTime()							-- last time we used a skill/ to calculate casting timer
		self.lastSkillTimer = profile['skillF3casttime']*1000		-- Casttime of used Spell			
--		yrest(profile['skillF3casttime']*1000)
		self.skillF3used = os.time()
		return		
	end
	if profile['skillF4use'] == true and os.difftime(os.time(),self.skillF4used) > profile['skillF4cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass4'])
		if profile['skillF4ground'] == true then
			keyboardPress(keySettings['skillclass4'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass4']))
		self.lastSkilluseTime = getTime()							-- last time we used a skill/ to calculate casting timer
		self.lastSkillTimer = profile['skillF4casttime']*1000		-- Casttime of used Spell			
--		yrest(profile['skillF4casttime']*1000)
		self.skillF4used = os.time()
		return		
	end
end

-- old style keypress to use until mem write works for all classes
function Player:useSkillsKeypress(_heal)

--	emergency heal?
	if (_heal) and
	   player.HP/player.MaxHP*100 < profile['healEmergency']  then
		logger:log('debug', "Need a emergency heal: %d/%d HP < %d", player.HP, player.MaxHP, profile['healEmergency'] );
		self.lastSkillTimer = 0   
	end

	-- check there is still a skill used/channeled 
	if deltaTime(getTime(), self.lastSkilluseTime ) < self.lastSkillTimer then	-- still other cast channeling?
--		logger:log('debug',"still casting: %d < %d)\n", deltaTime(getTime(), self.lastSkilluseTime ), self.lastSkillTimer );
		return
	end

	if _heal then
		if profile['skill6use'] == true and os.difftime(os.time(),self.skill6used) > profile['skill6cd'] + SETTINGS['lagallowance'] then
			keyboardPress(keySettings['skillheal'])
			if profile['skill6ground'] == true then
				keyboardPress(keySettings['skillheal'])
			end
			logger:log('info',"use heal skills at %d/%d health (healing startes at %d percent)\n", self.HP, self.MaxHP, self.Heal);
			cprintf(cli.green,"heal key %s\n", getKeyName(keySettings['skillheal']))
			yrest(profile['skill6casttime']*1000)
			self.skill6used = os.time()
			self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer			
		else		-- FIX/TODO: skill use often not fit, if the regular healuse didn't work we just press the key again without remembering the time
			keyboardPress(keySettings['skillheal'])
			if profile['skill6ground'] == true then
				keyboardPress(keySettings['skillheal'])
			end
			cprintf(cli.green,"heal key 6 emergency fix\n")
			yrest(profile['skill6casttime']*1000)
		end
		hpupdate()
--		return		-- FIX allow use of damage skills even if in heal mode
	end

	local dist = distance(self.X, self.Z, target.TargetX, target.TargetZ)

	if( dist > profile['fightdistance'] ) then
		return; -- Too far; don't use skills
	end

	if profile['skill2use'] == true and os.difftime(os.time(),self.skill2used) > profile['skill2cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon2'])
		if profile['skill2ground'] == true then
			keyboardPress(keySettings['skillweapon2'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillweapon2']))
		self.lastSkillTimer = profile['skill2casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill2casttime']*1000)
		self.skill2used = os.time() + profile['skill2casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer
		targetupdate()
		return
	end
	if profile['skill3use'] == true and os.difftime(os.time(),self.skill3used) > profile['skill3cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon3'])
		if profile['skill3ground'] == true then
			keyboardPress(keySettings['skillweapon3'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillweapon3']))
		self.lastSkillTimer = profile['skill3casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill3casttime']*1000)
		self.skill3used = os.time() + profile['skill3casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer
		targetupdate()
		return
	end
	if profile['skill4use'] == true and os.difftime(os.time(),self.skill4used) > profile['skill4cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon4'])	
		if profile['skill4ground'] == true then
			keyboardPress(keySettings['skillweapon4'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillweapon4']))
		self.lastSkillTimer = profile['skill4casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill4casttime']*1000)
		self.skill4used = os.time() + profile['skill4casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return
	end
	if profile['skill5use'] == true and os.difftime(os.time(),self.skill5used) > profile['skill5cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon5'])
		if profile['skill5ground'] == true then
			keyboardPress(keySettings['skillweapon5'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillweapon5']))
		self.lastSkillTimer = profile['skill5casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill5casttime']*1000)
		self.skill5used = os.time() + profile['skill5casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return		
	end
	if profile['skill7use'] == true and os.difftime(os.time(),self.skill7used) > profile['skill7cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillhelp1'])
		if profile['skill7ground'] == true then
			keyboardPress(keySettings['skillhelp1'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillhelp1']))
		self.lastSkillTimer = profile['skill7casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill7casttime']*1000)
		self.skill7used = os.time() + profile['skill7casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return		
	end
	if profile['skill8use'] == true and os.difftime(os.time(),self.skill8used) > profile['skill8cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillhelp2'])
		if profile['skill8ground'] == true then
			keyboardPress(keySettings['skillhelp2'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillhelp2']))
		self.lastSkillTimer = profile['skill8casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill8casttime']*1000)
		self.skill8used = os.time() + profile['skill8casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return
	end
	if profile['skill9use'] == true and os.difftime(os.time(),self.skill9used) > profile['skill9cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillhelp3'])
		if profile['skill9ground'] == true then
			keyboardPress(keySettings['skillhelp3'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillhelp3']))
		self.lastSkillTimer = profile['skill9casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill9casttime']*1000)
		self.skill9used = os.time() + profile['skill9casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return
	end
	if profile['skill0use'] == true and os.difftime(os.time(),self.skill0used) > profile['skill0cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillelite'])
		if profile['skill0ground'] == true then
			keyboardPress(keySettings['skillelite'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillelite']))
		self.lastSkillTimer = profile['skill0casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skill0casttime']*1000)
		self.skill0used = os.time() + profile['skill0casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return		
	end
	if profile['skillF1use'] == true and os.difftime(os.time(),self.skillF1used) > profile['skillF1cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass1'])
		if profile['skillF1ground'] == true then
			keyboardPress(keySettings['skillclass1'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass1']))
		self.lastSkillTimer = profile['skillF1casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skillF1casttime']*1000)
		self.skillF1used = os.time() + profile['skillF1casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return		
	end
	if profile['skillF2use'] == true and os.difftime(os.time(),self.skillF2used) > profile['skillF2cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass2'])
		if profile['skillF2ground'] == true then
			keyboardPress(keySettings['skillclass2'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass2']))
		self.lastSkillTimer = profile['skillF2casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skillF2casttime']*1000)
		self.skillF2used = os.time() + profile['skillF2casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return		
	end
	if profile['skillF3use'] == true and os.difftime(os.time(),self.skillF3used) > profile['skillF3cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass3'])
		if profile['skillF3ground'] == true then
			keyboardPress(keySettings['skillclass3'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass3']))
		self.lastSkillTimer = profile['skillF3casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skillF3casttime']*1000)
		self.skillF3used = os.time() + profile['skillF3casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return		
	end
	if profile['skillF4use'] == true and os.difftime(os.time(),self.skillF4used) > profile['skillF4cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillclass4'])
		if profile['skillF4ground'] == true then
			keyboardPress(keySettings['skillclass4'])
		end
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillclass4']))
		self.lastSkillTimer = profile['skillF4casttime']*1000		-- Casttime of used Spell
--		yrest(profile['skillF4casttime']*1000)
		self.skillF4used = os.time() + profile['skillF4casttime']
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		targetupdate()
		return		
	end
	if os.difftime(os.time(),self.skill1used) > profile['skill1cd'] then
		keyboardPress(keySettings['skillweapon1'])
		cprintf(cli.red,"attack key %s\n", getKeyName(keySettings['skillweapon1']))
		self.lastSkillTimer = profile['skill1casttime'] or 0.75
		self.lastSkillTimer = self.lastSkillTimer  * 1000
		self.lastSkilluseTime = getTime()			-- last time we used a skill/ to calculate casting timer		
		self.skill1used = os.time() + profile['skill1casttime']
		targetupdate()
	end	
end

function Player:logoutCheck()
-- timed logout check

	if(self.InCombat == true) then
		return;
	end;

	if( SETTINGS['botStopTime'] > 0 ) then
		local elapsed = os.difftime(os.time(), bot.startTimeBot);

		if( elapsed >= SETTINGS['botStopTime'] * 60 ) then
			logger:log('info',"Runtime of bot (%d minutes) >= configed runtime (%d minutes) ", elapsed/60, SETTINGS['botStopTime'] )	
			error("Bot stopped",2)
--			self:logout();
		end
	end
end