--[[
	Child of State class.
]]

include("../state.lua");

WaypointState = class(State);

function WaypointState:constructor(name)
	self.name = "Waypoint";
-- parameters
	self.index = 1;
	self.tableset = false
	self.waypoints = {};
	self.waypointname = name or "";
	self.lootwalk = false;	-- loot/interaction during walk
	self.laps = 0;			-- how often circle the wp file / 0=infinite 
-- help fields
	self.prevdist = 100000
	self.InteractTime = getTime();	-- last time we interact/loot
	self.interactionCount = 0; -- how often we interact at the same place
	self.interactionX = 0;		-- remember interaction place to avoid being sticked
	self.interactionZ = 0;	
	self.LapCounter = 0;		-- how often we have circled the wp file
	self.StartIndex = 0;		-- the WP index we start with

	self.lastTargetTime = getTime();
end

function WaypointState:update()
	if self.waypointname and not self.waypoints[1] then
		print("using name")
		self.waypointname = string.find(self.waypointname,"(.*).xml") or self.waypointname
		local file = BASE_PATH .. "/waypoints/" .. self.waypointname .. ".xml";
		print(file)
		if( fileExists(file) ) then	
			print("exists")
			self.waypoints = include(BASE_PATH .. "/waypoints/" .. self.waypointname .. ".xml", true);
		else
			logger:log('error',"Waypointfile %s not found", file);
			error("Waypointfile not found",1)
		end
		for i = 1,#self.waypoints do
			local wp = self.waypoints[i];
			local dist = distance(player.X, player.Z, wp.X, wp.Z)
			if self.prevdist > dist then 
				self.prevdist = dist 
				self.index = i 
			end
		end

		self.StartIndex = self.index	-- remeber WP we start with

		self.tableset = true
	elseif not self.waypointname and not self.waypoints[1] then	-- no wp file in waypoint state
--		self.waypoints = {								-- use actual position
--			{ X=player.X, Z=player.Z, Y=player.Y}
--		};
		stateman:pushEvent("Idle","waypoint");			-- go to idle state
		return
	end
	
	local wp = self.waypoints[self.index];
	if player:moveTo_step(wp.X, wp.Z, 100) then
		if( wp.type == "HARVEST" and player.Interaction ) then
					print("Harvesting");
			keyboardPress(key.VK_F);
		end
		self:advance()
	end
	
	statusupdate()	-- update Interaction
	
-- loot/interact during whole walking
-- usable at the end of events
	if self.lootwalk == true and	
	   player.Interaction == true and 
	   deltaTime(getTime(), self.InteractTime ) > 500 then	-- only ever 0.5 second
		if( self.interactionX == player.X) and	-- count interactions at the same spot
		  ( self.interactionZ == player.Z) then
			self.interactionCount = self.interactionCount + 1;
		else
			self.interactionCount = 0;		-- interaction at new place, clear counter
			-- we need that as long we can't separating looting from greeting
		end

		-- TODO: change against interaction type check
		if( self.interactionCount < 3 ) then		-- only 2 times at the same place
			self.interactionX = player.X;
			self.interactionZ = player.Z;
			keyboardPress(keySettings['interact']);		-- loot
			logger:log('info',"interaction/loot at (%d, %d)\n", player.X, player.Z);
			self.InteractTime = getTime();
		else
			logger:log('info',"no more interaction at that place (%d, %d)\n", player.X, player.Z);
		end
	end

	if( player.Interaction and player.InteractionId == 0x1403F ) then
		stateman:pushState(LootState(), "Walked over lootable.");
	end


	if( deltaTime(getTime(), self.lastTargetTime) > 500 ) then
		player:getNextTarget();
		
		if( player.TargetMob ) then
			targetupdate();
			if( distance(player.X, player.Z, target.TargetX, target.TargetZ) < profile['maxdistance'] ) then
				player:stopMoving();
				stateman:pushState(CombatState());
			end
		end

		self.lastTargetTime = getTime();
	end
end

function WaypointState:handleEvent(event)
	if( event == "entercombat" ) then
		player:stopMoving();
		stateman:pushState(CombatState());
	end
end

-- Advance the waypoint index to the next point.
function WaypointState:advance()
	self.index = self.index + 1;
	if( self.index > #self.waypoints ) then self.index = 1; end

-- count the laps
	if ( self.index == self.StartIndex ) then
		self.LapCounter = self.LapCounter + 1
		if( self.laps == self.LapCounter ) then		-- only x rounds 
			logger:log('info',"Finished waypoint state after %d rounds", self.laps)
			self.LapCounter = 0;
			stateman:popState("Waypoint");
		end
	end
	
	logger:log('info',"Waypoints advanced to #%d\n", self.index);
end

table.insert(events,{name = "Waypoint", func = WaypointState()})