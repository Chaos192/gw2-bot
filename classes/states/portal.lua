--[[
	Child of State class.
]]

include("../state.lua");

PortalState = class(State);

function PortalState:constructor()
	self.name = "Portal";
	self.index = 1;
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
				player:useSkills()
			end

			-- Check for loot
			local intObj = memoryReadInt(getProc(), addresses.Finteraction);
			--print("intObj:", intObj);
			if( intObj and intObj ~= 0 ) then
				keyboardPress(keySettings['interact']);
			end
		else
			player:useSkills()
		end
	else
		yrest(10000)
	end
end

function PortalState:handleEvent(event)
	if event == "Combat"  then
		logger:log('info',"Ignoring combat event, portal state.\n");
		return true;
	end
end
table.insert(events,{name = "Portal", func = PortalState()})