--[[
	Child of State class.
]]

include("../state.lua");

WaypointState = class(State);

function WaypointState:constructor()
	self.name = "Waypoint";
	self.index = 1;
	self.waypoints = {
	{ X=8821, Z=35262, Y=-266},
	{ X=9238, Z=35976, Y=-369},
	{ X=9531, Z=36582, Y=-442},
	{ X=9777, Z=37164, Y=-367},
	{ X=10060, Z=39034, Y=-320},
	{ X=10524, Z=39760, Y=-338},
	{ X=11143, Z=40277, Y=-330},
	{ X=12365, Z=40383, Y=-345},
	{ X=13587, Z=40789, Y=-334},
	{ X=14861, Z=41257, Y=-423},
	{ X=15787, Z=41576, Y=-288},
	{ X=14704, Z=41205, Y=-426},
	{ X=12924, Z=40546, Y=-415},
	{ X=12298, Z=40346, Y=-340},
	{ X=11175, Z=40259, Y=-329},
	{ X=10231, Z=39411, Y=-333},
	{ X=9946, Z=38167, Y=-312},
	{ X=9761, Z=37085, Y=-368},
	{ X=9338, Z=36179, Y=-403},			
	};
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