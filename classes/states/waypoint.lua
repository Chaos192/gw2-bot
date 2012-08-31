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
	local prevdist = 100000
	for i = 1,#self.waypoints do
		local wp = self.waypoints[i];
		local dist = distance(player.X, player.Z, wp.X, wp.Z)
		if prevdist > dist then 
			prevdist = dist 
			self.index = i 
		end
	end
end

function WaypointState:update()
	if waypoint and not self.tableset then
		waypoint = string.find(waypoint,"(.*).xml") or waypoint
		local file = BASE_PATH .. "/waypoints/" .. waypoint .. ".xml";
		if( fileExists(file) ) then	
			self.waypoints = include(BASE_PATH .. "/waypoints/" .. waypoint .. ".xml", true);
		end
		local prevdist = 100000
		for i = 1,#self.waypoints do
			local wp = self.waypoints[i];
			local dist = distance(player.X, player.Z, wp.X, wp.Z)
			if prevdist > dist then 
				prevdist = dist 
				self.index = i 
			end
		end

		self.tableset = true
	end
	local wp = self.waypoints[self.index];

	-- Check our angle to the waypoint.
	local angle = math.atan2(wp.Z - player.Z, wp.X - player.X) + math.pi;
	local anglediff = player.Angle - angle;

	if( math.abs(anglediff) > 0.13 ) then

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
		-- We're facing the point. Move forward.
		if( player.turnDir ) then
			player:stopTurning();
		end
		if distance(wp.Z, wp.X, player.Z, player.X) > 40 then
			player:moveForward();
		else
			self:advance()
		end
	end
end

-- Advance the waypoint index to the next point.
function WaypointState:advance()
	self.index = self.index + 1;
	if( self.index > #self.waypoints ) then self.index = 1; end

	logger:log('info',"Waypoints advanced to #%d\n", self.index);
end

table.insert(events,{name = "Waypoint", func = WaypointState()})