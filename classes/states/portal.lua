--[[
	Child of State class.
]]

include("../state.lua");

PortalState = class(State);

function PortalState:constructor()
	self.name = "Portal";
	self.index = 1;
	self.selfskill2used = os.time()
	self.selfskill3used = os.time()
	self.selfskill5used = os.time()
	self.selfskill8used = os.time()
	self.selfskill2cd = 7
	self.selfskill3cd = 11
	self.selfskill5cd = 31
	self.selfskill8cd = 61

	self.destX = -11087;
	self.destZ = -4374;
end

function PortalState:update()
	if player.HP > 10 then

		if distance(self.destX, self.destZ, player.X, player.Z) > 40 then
			player:moveTo_step(self.destX, self.destZ);
		elseif( player.fbMovement ) then
			player:stopMoving();

		elseif player.TargetMob == 0 then
			local angle = math.atan2(-4421 - player.Z, -11194 - player.X) + math.pi;
			local anglediff = player.Angle - angle;

			if( math.abs(anglediff) > 0.13 ) then -- 0.26 radians is ~15 degrees

				if( player.fbMovement ) then -- Stop running forward.
					player:stopMoving();
				end

				-- Attempt to face it
				if( anglediff < 0 or anglediff > math.pi ) then
					-- Rotate left
					player:turnLeft();
				else
					-- Rotate right
					player:turnRight();
				end
			else
				-- We're facing the point.
				if( player.turnDir ) then
					player:stopTurning();
				end
				self:useskills()
			end

			-- Check for loot
			local intObj = memoryReadInt(getProc(), addresses.Finteraction);
			--print("intObj:", intObj);
			if( intObj and intObj ~= 0 ) then
				keyboardPress(Settings['interact']);
			end
		else
			self:useskills()
		end
	else
		yrest(10000)
	end
end
function PortalState:useskills()
	if player.Heal > player.HP/player.MaxHP*100 then
		keyboardPress(key.VK_6)
	end				
	if os.difftime(os.time(),self.selfskill2used) > self.selfskill2cd then
		keyboardPress(key.VK_2)
		--keyboardPress(key.VK_2) -- target ground skill
		self.selfskill2used = os.time()
		cprintf(cli.red,"attack 2\n")
	end
	if os.difftime(os.time(),self.selfskill3used) > self.selfskill3cd then
		keyboardPress(key.VK_3)	
		self.selfskill3used = os.time()
		cprintf(cli.red,"attack 3\n")
	end
	if os.difftime(os.time(),self.selfskill5used) > self.selfskill5cd then
		keyboardPress(key.VK_5)
		--keyboardPress(key.VK_5) -- target ground skill
		self.selfskill5used = os.time()
		cprintf(cli.red,"attack 5\n")	
	end
	if os.difftime(os.time(),self.selfskill8used) > self.selfskill8cd then
		keyboardPress(key.VK_8)
		--keyboardPress(key.VK_8) -- target ground skill
		self.selfskill8used = os.time()		
		cprintf(cli.red,"attack 8\n")		
	end
	keyboardPress(key.VK_1)	
end