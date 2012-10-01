--[[
	Child of State class.
]]

include("../state.lua");

WaypointState = class(State);

function WaypointState:constructor(name)
	self.name = "Waypoint";
-- parameters
	self.index = 1;
	self.startIndex = 0;		-- the WP index we start with
	self.tableset = false
	self.waypoints = {};
	self.waypointname = "";	
	if name then			-- load WPs from path file (set also index and startIndex)
		self:loadPath(name)
	end
	
	self.lootwalk = false;	-- loot/interaction during walk
	self.laps = 0;			-- how often circle the wp file / 0=infinite 
	self.getTarget = true	-- active looking for new targets
	self.stopAtEnd = false	-- stop Waypointfile at end of Waypoints (usabel for going from A -> B )
-- help fields
	self.InteractTime = getTime();	-- last time we interact/loot
	self.interactionCount = 0; -- how often we interact at the same place
	self.interactionX = 0;		-- remember interaction place to avoid being sticked
	self.interactionZ = 0;	
	self.LapCounter = 0;		-- how often we have circled the wp file

	self.lastTargetTime = getTime();
end

function WaypointState:update()
	logger:log('debug-states',"WaypointState:update()");

-- load WP path if WPs not already there
	if self.waypointname and not self.waypoints[1] then	-- load WPs from file if WP table empty
		self:loadPath(self.waypointname)
	elseif not self.waypointname and not self.waypoints[1] then	-- no wp file in waypoint state
		stateman:pushEvent("Idle","waypoint");			-- go to idle state
		return
	end

	statusupdate()		-- update Interaction
	targetupdate()		-- to get target cleared

	local wp = self.waypoints[self.index];
	if not wp then logger:log('error',"Error in waypoints or waypoint file. Please check the waypoints or the waypoint file"); end
	
--debug_value(player.Interaction,"player.Interaction")	
	if player:moveTo_step(wp.X, wp.Z) then
		if( wp.type == "HARVEST" and player.Interaction ) then
			logger:log('info',"Harvesting at WP (%d, %d) %s\n", wp.X, wp.Z, wp.comment);
			keyboardPress(keySettings['interact']);
			yrest(5000)		-- TODO: harvesting state? or just not moving but still fight?
			statusupdate()		-- update Interaction
		end
		self:advance()			-- advance to next WP
	end
-- TODO: unstick here or at player:moveTo_step() if WP never reached
	

-- loot/interact during whole walking
-- usable at the end of events
	if self.lootwalk == true and	
		player.Interaction == true and
	    player.Ftext ~= language:message('InteractGreeting') and
	    player.Ftext ~= language:message('InteractTalk')  and		-- not if only greeting
--		player.InteractionId == 0x1403F and -- Make sure it is actually loot  / NOT WORKING ATM
-- BUG: if we 'loot' and don't wait until finished (5 sec) we can't walk anymore
-- that happens if we not reach the harves WP and instead first try to loot it
-- would be ok if we can check the interactionID
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
			stateman:pushState(LootState(), "Walked over lootable.");		-- loot
			logger:log('info',"interaction/loot at (%d, %d)\n", player.X, player.Z);
			self.InteractTime = getTime();
		else
			logger:log('info',"no more interaction at that place (%d, %d)\n", player.X, player.Z);
		end
	end


-- target new mob
	if( deltaTime(getTime(), self.lastTargetTime) > 500 ) and
	  ( self.getTarget == true ) then	-- active looking for new targets
		player:getNextTarget();
		
		if( player.TargetMob ) then
			targetupdate();
			if( distance(player.X, player.Z, target.TargetX, target.TargetZ) < profile['maxdistance'] ) then
				player:stopMoving();
				player:stopTurning();
				stateman:pushState(CombatState());
			end
		end

		self.lastTargetTime = getTime();
	end
end

function WaypointState:handleEvent(event)
	if( event == "entercombat" ) then
		player:stopMoving();
		player:stopTurning();
		stateman:pushState(CombatState());
	end
end

-- Advance the waypoint index to the next point.
function WaypointState:advance()
	self.index = self.index + 1;

	if( self.index > #self.waypoints ) then 	-- we are at the last waypoint 

		-- stop at end of waypoint file
		if( self.stopAtEnd == true )  and		-- should stop at last waypoint
		  ( self.LapCounter == self.laps ) then	-- after x rounds ( could also be 0, means directly at last WP) 
			logger:log('info',"Finished waypoint file at the last waypoint")
			stateman:popState("Waypoint");
		end

		self.index = 1; 		-- go back to wp #1
	end

-- count the laps
	if ( self.index == self.startIndex ) then
		self.LapCounter = self.LapCounter + 1
		if( self.laps == self.LapCounter ) then		-- only x rounds 
			logger:log('info',"Finished waypoint state after %d rounds", self.laps)
			self.LapCounter = 0;
			stateman:popState("Waypoint");
		end
	end
	
	local hf_comment = "";			
	local wp = self.waypoints[self.index];
	if wp.comment then hf_comment = "("..wp.comment..")"; end;	-- print comment from WP / helps to match file with wp run
	
	logger:log('info',"Waypoints advanced to #%d %s\n", self.index, hf_comment);
end

-- search for the nearest WP in path to actual player position
-- could be used to switch to return or unstick path
-- return: distance to closest waypoint, # of waypoint
-- TODO: use also Y value to determine distance
function WaypointState:distanceToPath()

	coordsupdate()
	local hf_nearest = 999999999

	for i = 1,#self.waypoints do
		local wp = self.waypoints[i];
		local dist = distance(player.X, player.Z, wp.X, wp.Z)
		if dist < hf_nearest then 
			hf_nearest = dist 
			self.index = i 
		end
	end

	return hf_nearest, self.index

end


-- load WP path from file
function WaypointState:loadPath(_filename)

	self.waypointname = string.find(_filename,"(.*).xml") or _filename
	local file = BASE_PATH .. "/waypoints/" .. self.waypointname .. ".xml";
	if( fileExists(file) ) then	
		self.waypoints = include(BASE_PATH .. "/waypoints/" .. self.waypointname .. ".xml", true);
		logger:log('info',"Load path with %d waypoints from file %s", #self.waypoints, file);
	else
		logger:log('error',"Waypointfile %s not found", file);
		error("Waypointfile not found",1)
	end

	-- determine nearest WP within path and set as index / StartIndex
	local prevdist = 999999999
	coordsupdate()
	for i = 1,#self.waypoints do
		local wp = self.waypoints[i];
		local dist = distance(player.X, player.Z, wp.X, wp.Z)
		if dist < prevdist then 
			prevdist = dist 
			self.index = i 
		end
	end

	self.startIndex = self.index	-- remeber WP we start with

	self.tableset = true
end



table.insert(events,{name = "Waypoint", func = WaypointState()})