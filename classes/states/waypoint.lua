--[[
	Child of State class.
]]

include("../state.lua");

WaypointState = class(State);

function WaypointState:constructor()
	self.name = "Waypoint";
	self.index = 1;
	self.waypoints = {
		{X = 5609, Y = -14253, Z = 7922},
		{X = 5261, Y = -14254, Z = 7831},
	};
end

function WaypointState:update()
	local wp = self.waypoints[self.index];

	-- Check our angle to the waypoint.
	local angle = math.atan2(wp.Z - player.Z, wp.X - player.X) + math.pi;
	local anglediff = player.Angle - angle;

	--print("A:", math.abs(anglediff))
	if( math.abs(anglediff) > 0.26 ) then -- 0.26 radians is ~15 degrees

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

		player:moveForward();
	end
end

-- Advance the waypoint index to the next point.
function WaypointState:advance()
	self.index = self.index + 1;
	if( self.index > #self.waypoints ) then self.index = 1; end

	logger:log('info',"Waypoints advanced to #%d\n", self.index);
end

table.insert(events,{name = "Waypoint", func = WaypointState()})