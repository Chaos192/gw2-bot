--[[
	Child of State class.
]]

include("../state.lua");

WaypointState = class(State);

function WaypointState:constructor()
	self.name = "Waypoint";
	self.index = 1;
	self.tableset = false
	self.waypoints = {};
	self.waypointname = ""
	self.prevdist = 100000
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
		end
		for i = 1,#self.waypoints do
			local wp = self.waypoints[i];
			local dist = distance(player.X, player.Z, wp.X, wp.Z)
			if self.prevdist > dist then 
				self.prevdist = dist 
				self.index = i 
			end
		end

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

	logger:log('info',"Waypoints advanced to #%d\n", self.index);
end

table.insert(events,{name = "Waypoint", func = WaypointState()})