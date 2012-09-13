--[[
	Child of State class.
]]

include("../state.lua");

WaypointState = class(State);

function WaypointState:constructor()
	self.name = "Waypoint";
-- parameters
	self.index = 1;
	self.tableset = false
	self.waypoints = {};
	self.waypointname = ""
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
end

function WaypointState:update()
	if waypoint.waypointname and not self.waypoints[1] then
		print("using name")
		waypoint.waypointname = string.find(waypoint.waypointname,"(.*).xml") or waypoint.waypointname
		local file = BASE_PATH .. "/waypoints/" .. waypoint.waypointname .. ".xml";
		print(file)
		if( fileExists(file) ) then	
			print("exists")
			self.waypoints = include(BASE_PATH .. "/waypoints/" .. waypoint.waypointname .. ".xml", true);
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
			printf("Harvesting\n");
			keyboardPress(key.VK_F);
		end
		self:advance()
	end
	
	statusupdate()	-- update Interaction
	
-- loot/interact during whole walking
-- usable at the end of events
	if waypoint.lootwalk == true and	
	   player.Interaction == true and 
	   deltaTime(getTime(), self.InteractTime ) > 300 then	-- only ever 0.3 second
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

-- count the laps
	if ( self.index == self.StartIndex ) then
		self.LapCounter = self.LapCounter + 1
		if( waypoint.laps == self.LapCounter ) then		-- only x rounds 
			logger:log('info',"Finished waypoint state after %d rounds", waypoint.laps)
			self.LapCounter = 0;
			stateman:popState("Waypoint");
		end
	end

	
	if( self.index > #self.waypoints ) then self.index = 1; end

	logger:log('info',"Waypoints advanced to #%d\n", self.index);
end

table.insert(events,{name = "Waypoint", func = WaypointState()})